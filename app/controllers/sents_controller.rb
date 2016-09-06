class SentsController < ApplicationController
  before_action :set_sent, only: [:show, :edit, :update, :destroy]
  include SentsHelper
  include OrdersHelper
  # GET /sents
  # GET /sents.json
  def index
    @sents = Sent.where(owner_type: Order.name)

    if params[:start_at].present? && params[:end_at].present?
      @sents = @sents.where("sent_at between ? and ?", params[:start_at], params[:end_at])
    elsif params[:start_at].present? || params[:end_at].present?
      @sents = @sents.where("sent_at = ? ", params[:start_at].present? ? params[:start_at] : params[:end_at])
    end

    if params[:agent_id].present?
      indent = Indent.find_by(agent_id: params[:agent_id])
      @sents = Sent.where(owner_type: Order.name, owner_id: indent.orders.map(&:id)) if indent.present?
      # @sents = @sents.joins(:indent).where("indents.agent_id = ?", params[:agent_id])
    end

    if params[:order_name].present?
      order = Order.find_by_name(params[:order_name])
      @sents = @sents.where(owner_id: order.id)
      #@sents = @sents.joins(:indent).where("indents.name = ?", params[:indent_name].to_s)
    end
    @sent = Sent.new
  end

  # GET /sents/1
  # GET /sents/1.json
  def show
  end

  # GET /sents/new
  def new
    @sent = Sent.new
  end

  # GET /sents/1/edit
  def edit
  end

  # POST /sents
  # POST /sents.json
  def create
    @sent = Sent.new(sent_params)

    respond_to do |format|
      if @sent.save
        if @sent.owner_type == 'Indent'
          # 所有已打包的子订单添加发货记录
          @sent.owner.orders.each do |order|
            next unless order.packaged?
            o_sent = Sent.new(sent_params)
            o_sent.owner_id = order.id
            o_sent.owner_type = order.class.name
            o_sent.save!
          end
        end
        format.html { redirect_to not_sent_orders_path, notice: '发货信息创建成功！' }
      else
        format.html { redirect_to not_sent_orders_path, notice: '发货信息创建失败！' }
      end
    end
  end

  # GET
  # 添加发货信息
  def change
    @sent = params[:id].present? ? Sent.find_by_id(params[:id]) : Sent.new
    case params[:type]
      when 'indent'
        @indent_or_order = Indent.find_by_id(params[:indent_or_order_id])
      when 'order'
        @indent_or_order = Order.find_by_id(params[:indent_or_order_id])
      else
        @indent_or_order = nil
    end
    render layout: false
  end

  # GET
  # 补充发货单单中的货单号
  def replenish
    @sent = Sent.find_by_id(params[:id]) if params[:id].present?
    render layout: false
  end

  # PATCH/PUT /sents/1
  # PATCH/PUT /sents/1.json
  def update
    respond_to do |format|
      if @sent.update(sent_params)

        if @sent.owner_type == 'Indent'
          # 所有已打包的子订单添加发货记录
          @sent.owner.orders.each do |order|
            next unless order.packaged?
            o_sent = order.sent
            o_sent.present? ? o_sent.update_attributes(sent_params) : o_sent = Sent.new(sent_params)
            o_sent.owner_id = order.id
            o_sent.owner_type = order.class.name
            o_sent.save!
          end
        end

        # 发货单的发货时间、物流回执单号不为空时，更新订单状态
        if @sent.sent_at.present? && @sent.logistics_code.present?
          if @sent.owner_type == Indent.name
            indent = Indent.find_by_id(@sent.owner_id)
            indent.sent!
          elsif @sent.owner_type == Order.name
            Order.find_by_id(@sent.owner_id).sent!
          else
            # 更新订单状态错误
          end
        end
        format.html { redirect_to :back, notice: '发货单编辑成功！' }
      else
        format.html { redirect_to :back, error: '发货单编辑失败！' }
      end
    end
  end

  # 下载发货清单
  # GET /sent_list
  # GET /sent_list.xls
  def download
    if params[:id].present?
      sent_list = SentList.find_by_id(params[:id])
    else
      sents = Sent.where(id: params[:sent][:ids].split(','))
      sent_list = SentList.create(total: sents.size, created_by: Time.new.strftime('%Y-%m-%d %H:%M:%S'))
      sents.each do |s|
        s.sent_list_id = sent_list.id
        s.save!
        s.owner.sending!
        update_order_status(s.owner)
      end
      export_sent_list(sent_list)
    end
    
    respond_to do |format|
      # 根据访问时是否指定后缀名，而返回不同结果(例如：访问/sents/download.xls 返回 xls 格式文件)
      format.html {redirect_to not_sent_orders_path, notice: '发货清单创建成功！'}
      format.xls do
        send_file "#{Rails.root}/public/excels/sent_lists/" + sent_list.name + ".xls", type: 'text/xls; charset=utf-8'
        #response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.csv"'
        #render text: to_csv(sents)
      end
      format.pdf do
        # 打印尺寸毫米（长宽）
        pdf = SentListPdf.new(sent_list)
        send_data pdf.render, filename: "发货清单#{sent_list.name}.pdf",
          type: "application/pdf",
          disposition: "inline"
      end
    end
  end

  # DELETE /sents/1
  # DELETE /sents/1.json
  def destroy
    order = @sent.owner
    sent_list = @sent.sent_list
    @sent.destroy
    order.packaged! # 将子订单状态改回上一步“已打包”
    update_order_status(order)
    if sent_list.sents.size == 0
      sent_list.destroy!
      File.delete("#{Rails.root}/public/excels/sent_lists/" + sent_list.name + ".xls")
      redirect_to sent_lists_path, notice: '发货记录已删除！'
    else
      redirect_to :back, notice: '发货记录已删除！'
    end
  end

  def to_csv(object)
    return [] if object.nil?
    # make excel using utf8 to open csv file
    head = 'EF BB BF'.split(' ').map{|a|a.hex.chr}.join()
    total = 0
    CSV.generate(head) do |csv|
      headers = [Time.new.strftime('%Y-%m-%d'),'发货清单']
      csv << headers
      # 获取字段名称
      column_names = [ '序号', '地区', '收货人', '联系方式', '订单编号', '橱', '衣', '门', '配', '合计', '代收', '物流名称', '货号']
      csv << column_names
      object.each_with_index do |obj,i|
        total += obj.cupboard + obj.robe + obj.door + obj.part
        values = []
        values << i+1
        values << obj.area
        values << obj.receiver
        values << "\t" + obj.contact
        values << obj.owner.name
        values << obj.cupboard
        values << obj.robe
        values << obj.door
        values << obj.part
        values << obj.cupboard + obj.robe + obj.door + obj.part
        values << obj.collection
        values << obj.logistics
        csv << values
      end
      footer = [ '', '', '', '', '', '', '', '', '', '', "打单时间:#{Time.new.strftime('%Y-%m-%d %H:%M:%S')}", "合计#{total}", '']
      csv << footer
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sent
      @sent = Sent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sent_params
      params.require(:sent).permit(:id, :sent_list_id, :name, :sent_at, :area, :receiver, :contact, :cupboard, :robe, :door, 
                                   :part, :collection, :collection, :logistics, :logistics_code, :owner_id, :owner_type)
    end
end
