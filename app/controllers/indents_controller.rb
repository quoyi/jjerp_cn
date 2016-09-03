class IndentsController < ApplicationController
  include IndentsHelper
  include OrdersHelper
  include OffersHelper
  before_action :set_indent, only: [:show, :edit, :update, :destroy]

  # GET /indents
  # GET /indents.json
  def index
    @agent = Agent.new(name: "DL".upcase() + (Agent.count+1).to_s.rjust(4, "0"))
    # @agents = Agent.all
    now = Time.now
    after_ten_day = Time.now + 864000 # 十天 = 60 (秒钟/分钟) * 60 (分钟/天) * 24 (小时/天) * 10
    @indent = Indent.new(name: Time.now.strftime("%y%m%d") + SecureRandom.hex(1).upcase, verify_at: Time.now, require_at: after_ten_day)

    # @current_agent = @indent.agent ||  @agents.first

    @income = @indent.incomes.new(username: current_user.name, income_at: now)

    @indents = Indent.all.order(created_at: :desc)
    @start_at = Date.today.beginning_of_month.to_s
    @end_at = Date.today.end_of_month.to_s
    if params[:start_at].present? && params[:end_at].present?
      @start_at = params[:start_at]
      @end_at = params[:end_at]
    end
    @indents = @indents.where("verify_at between ? and ?", @start_at, @end_at)

    if params[:agent_id].present?
      @indents = @indents.where(agent_id: params[:agent_id])
    end
  end

  # GET /units/1
  # GET /units/1.json
  def show
    @agent = Agent.new(name: "DL".upcase() + (Agent.count+1).to_s.rjust(4, "0"))
    @order = Order.new
    @order_offers = @indent.offers
    @orders = Order.where(indent:@indent).order(created_at: :desc)
  end

  # GET /indents/new
  def new
    @indent = Indent.new
  end

  # GET /indents/1/edit
  def edit
    @agent = Agent.new
    @indent = Indent.find_by_id(params[:id])
    render layout: false
  end

  # POST /indents
  # POST /indents.json
  def create
    @indent = Indent.new(indent_params)
    if @indent.save
      redirect_to indents_path, notice: '订单创建成功！'
    else
      redirect_to indents_path, error: '请检查编号是否唯一且数据正确，订单创建失败！'
    end
  end

  # PATCH/PUT /indents/1
  # PATCH/PUT /indents/1.json
  def update
    if @indent.update(indent_params)
      @indent.orders.each do |o|
        update_order_and_indent(o)
        update_order_status(o)
      end
      if @indent.status == 'producing'
        msg = "订单: #{@indent.name} 开始生产！"
      else
        msg = "订单编辑成功！"
      end
      redirect_to :back, notice: msg
    else
      redirect_to :back, error: "订单编辑失败！"
    end
  end

  # DELETE /indents/1
  # DELETE /indents/1.json
  def destroy
    # 需要标记删除，不能真正地删除
    @indent.destroy
    redirect_to indents_path, notice: '订单已删除。'
  end

  # 生成报价单
  def generate
    # 查找订单的所有拆单信息，并生成报价单
    indent = Indent.find_by_id(params[:id])
    indent.orders.each do |order|
      create_offer(order)
      update_order_status(order)
    end
    # update_indent_status(indent)
    redirect_to indent_path(indent), notice: '生成报价单成功！'
  end

  # 导出报价单
  def export_offer
    @indent = Indent.find_by_id(params[:id])
    export_offers(@indent)
    respond_to do |format|
      format.html { redirect_to order_union_path(@indent), notice: '导出成功' }
      format.json { head :no_content }
      # format.csv do
      #   filename = "报价单－" + @indent.name
      #   response.headers['Content-Type'] = "application/vnd.ms-excel"
      #   response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.csv"'
      #   render text: to_csv(@indent)
      # end
      format.xls do
        send_file "#{Rails.root}/public/excels/offers/" + @indent.name + ".xls", type: 'text/xls; charset=utf-8'
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_indent
    @indent = Indent.find(params[:id])
  end

  # 下载报价单并转换为csv
  def to_csv(indent)
    return [] if indent.nil?
    offers = indent.offers
    # make excel using utf8 to open csv file
    # head = 'EF BB BF'.split(' ').map{|a|a.hex.chr}.join()
    # head = '\xEF\xBB\xBF'.split(' ').map{|a|a.hex.chr}.join()
    # head = ""
    CSV.generate do |csv|
      # 获取字段名称
      csv << ["总订单号", indent.name, '代理商', indent.agent.full_name,
              '终端客户', indent.customer, '套数', indent.orders.map(&:number).sum()]
      csv << ['下单时间', indent.verify_at, '发货时间', indent.require_at, '状态', indent.status_name,
              '金额￥', offers.map{|o| o.order.number * o.total}.sum()]
      csv << ['序号', '类型', '名称', '单价￥', '单位', '数量', '备注', '总价￥']
      offers.group_by(&:order_id).each_pair do |order_id, offers|
        offers.each_with_index do |offer, index|
          values = []
          values << index + 1
          values << offer.item_type_name
          values << offer.item_name
          values << offer.price
          values << offer.uom
          values << offer.number
          values << offer.note
          values << offer.total
          csv << values
        end
        order = offers.first.order
        order_total = offers.map(&:total).sum()
        orders_total = order_total * order.number
        csv << ['子订单号', order.name, '单套合计￥', order_total, '单项套数', order.number,
                '项目合计￥', orders_total]
        csv << ['', '', '', '', '', '', '', '']
      end
    end.encode('gb2312', :invalid => :replace, :undef => :replace, :replace => "?")
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def indent_params
    # if params[:indent][:orders_attributes].present?
    #   params[:indent][:orders_attributes].each_pair do |k, v|
    #     # v[:name] = params[:indent][:name].to_s
    #     v[:status] = Order.statuses[v[:status]]
    #   end
    # end
    params.require(:indent).permit(:id, :name, :offer_id, :agent_id, :customer, :verify_at, :require_at, :note, :address,
                                   :logistics, :amount, :arrear, :total_history, :total_arrear, :deleted, :status,
                                   orders_attributes: [:id, :order_category_id, :customer, :number, :ply, :material_price,
                                                       :texture, :color, :price, :length, :width, :height, :oftype,
                                                       :note, :is_use_order_material, :delivery_address, :_destroy],
                                   offers_attributes: [:id, :order_id, :item_id, :item_type, :item_name,
                                                       :uom, :number, :price, :note, :_destroy])
     # _return[:orders_attributes].each_pair{|k,v| v[:type] = Order.types[v[:type]] }
     # return _return
  end
end
