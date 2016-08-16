class SentsController < ApplicationController
  before_action :set_sent, only: [:show, :edit, :update, :destroy]
  include OrdersHelper
  # GET /sents
  # GET /sents.json
  def index
    @sents = Sent.all

    if params[:start_at].present? && params[:end_at].present?
      @sents = @sents.where("sent_at between ? and ?", params[:start_at], params[:end_at])
    elsif params[:start_at].present? || params[:end_at].present?
      @sents = @sents.where("sent_at = ? ", params[:start_at].present? ? params[:start_at] : params[:end_at])
    end

    if params[:agent_id].present?
      @sents = @sents.joins(:indent).where("indents.agent_id = ?", params[:agent_id])
    end

    if params[:indent_name].present?
      @sents = @sents.joins(:indent).where("indents.name = ?", params[:indent_name].to_s)
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
          @sent.owner.orders.each do |order|
            o_sent = Sent.new(sent_params)
            o_sent.owner_id = order.id
            o_sent.owner_type = order.class.name
            o_sent.save!
          end
        end
        format.html { redirect_to not_sent_indents_path, notice: '发货创建成功！' }
      else
        format.html { redirect_to not_sent_indents_path, notice: '发货创建失败！' }
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
      # binding.pry
      if @sent.update(sent_params)

        if @sent.owner_type == 'Indent'
          @sent.owner.orders.each do |order|
            o_sent = order.sent
            o_sent.update_attributes(sent_params)
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
        format.html { redirect_to not_sent_indents_path, notice: '发货单编辑成功！' }
      else
        format.html { redirect_to not_sent_indents_path, error: '发货单编辑失败！' }
      end
    end
  end

  def download
    sents = Sent.where(id: params[:sent][:ids].split(','))
    sent_list = SentList.create(total: sents.size)
    sents.each do |s|
      s.sent_list_id = sent_list.id
      s.save!
      s.owner.sending!
      update_order_status(s.owner)
    end
    # binding.pry
    respond_to do |format|
      format.csv do
        filename = "发货清单_"
        datetime = Time.new.strftime('%Y%m%d%H%M%S')
        filename += datetime
        response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.csv"'
        render text: to_csv(sents)
      end
    end
  end

  # DELETE /sents/1
  # DELETE /sents/1.json
  def destroy
    @sent.destroy
    respond_to do |format|
      format.html { redirect_to sents_url, notice: 'Sent was successfully destroyed.' }
      format.json { head :no_content }
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
