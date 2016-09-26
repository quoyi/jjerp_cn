class IndentsController < ApplicationController
  include IndentsHelper
  include OrdersHelper
  include OffersHelper
  before_action :set_indent, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => [:part_list]

  # GET /indents
  # GET /indents.json
  def index
    @agent = Agent.new(name: "DL".upcase() + (Agent.count+1).to_s.rjust(4, "0"))
    # @agents = Agent.all
    now = Time.now
    after_ten_day = Time.now + 864000 # 十天 = 60 (秒钟/分钟) * 60 (分钟/天) * 24 (小时/天) * 10
    @indent = Indent.new(name: Time.now.strftime("%Y%m%d") + SecureRandom.hex(1).upcase, verify_at: Time.now, require_at: after_ten_day)

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

    @indents = @indents.page(params[:page])
  end

  # GET /units/1
  # GET /units/1.json
  def show
    @agent = Agent.new(name: "DL".upcase() + (Agent.count+1).to_s.rjust(4, "0"))
    @order = Order.new
    @order_offers = @indent.offers
    @orders = Order.where(indent:@indent).order(created_at: :desc)
    @income = Income.new(bank_id: Bank.find_by(is_default: 1).id, username: current_user.name, income_at: Time.now)
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
    # 新建总订单时，修改代理商欠款
    Indent.transaction do
      @indent = Indent.new(indent_params)
      # 保存新总订单之前，先获取总订单 （原）金额，后面需要减 （原）金额
      origin_indent_amount = @indent.orders.pluck(:price).sum
      @indent.save!
      agent = @indent.agent
      agent.update!(arrear: agent.arrear + @indent.amount - origin_indent_amount, 
                    history: agent.history + @indent.amount - origin_indent_amount)
    end
    
    if @indent
      redirect_to indents_path, notice: '订单创建成功！'
    else
      redirect_to indents_path, error: '请检查编号是否唯一且数据正确，订单创建失败！'
    end
  end

  # PATCH/PUT /indents/1
  # PATCH/PUT /indents/1.json
  def update
    Indent.transaction do
      # 获取删除的 orders
      # 更新总订单之前，先获取总订单 （原）金额，后面需要减 （原）金额
      origin_indent_amount = @indent.orders.pluck(:price).sum
      origin_indent_arrear = @indent.orders.pluck(:arrear).sum
      @indent.update!(indent_params)
      # 更新总订单金额
      @indent.update!(amount: @indent.orders.pluck(:price).sum, arrear: @indent.orders.pluck(:arrear).sum,
                      status: @indent.orders.map{|o|Order.statuses[o.status]}.min || 0)
      indent_remain = origin_indent_amount - @indent.amount
      agent = @indent.agent
      agent.update!(balance: agent.balance + indent_remain, arrear: agent.arrear + @indent.arrear - origin_indent_arrear, 
                    history: agent.history + @indent.amount - origin_indent_amount)
    end

    redirect_to :back, notice: "订单编辑成功！"
  end

  # DELETE /indents/1
  # DELETE /indents/1.json
  def destroy
    Indent.transaction do
      agent = @indent.agent
      agent.update!(arrear: agent.arrear - @indent.amount, 
                    history: agent.history - @indent.amount)
      # 删除所有子订单
      @indent.orders.destroy_all
      @indent.destroy!
    end
    redirect_to indents_path, notice: '订单已删除。'
  end

  # 到款详细
  def incomes
    @indent = Indent.find_by_id(params[:id]) if params[:id].present?
    @incomes = @indent.incomes
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
      format.html { redirect_to order_union_path(@indent), notice: '报价单导出成功' }
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

  # 导出配件清单
  def export_parts
    respond_to do |format|
      format.html { redirect_to indents_path, notice: '配件清单导出成功' }
      format.xls do
        send_file "#{Rails.root}/public/excels/parts/" + params[:file_name] + ".xls", type: 'text/xls; charset=utf-8'
      end
    end
    # 不能删，否则下载时找不到文件
    # File.delete("#{Rails.root}/public/excels/parts/" + params[:file_name] + ".xls")
  end

  # 配件清单预览(返回结果如下：)
  # @result = {indent_id: {indent: indent; cupboard: [cupboard_parts]; others: [other_parts]}; ... }
  def preview
    @result = {}
    if params[:ids].present?
      ids = params[:ids].split(",")
      @indents = Indent.where(id: ids).order(created_at: :desc)
      # 添加文件名称，方便下载使用
      @result["file_name"] = "配件清单-" + Time.now.strftime("%Y%m%d-") + SecureRandom.hex(2).upcase
      @indents.each do |indent|
        indent_parts = {}
        indent_parts["indent"] = indent
        # 橱柜体单独统计配件
        cupboard_orders = indent.orders.where(order_category_id: OrderCategory.find_by(name: "橱柜").id)
        cupboard_parts = cupboard_orders.map{|o| o.parts}.flatten
        indent_parts["cupboard_orders_name"] = cupboard_orders.pluck(:name)
        # 其他订单类型 一起统计配件
        other_orders = indent.orders.where.not(order_category_id: OrderCategory.find_by(name: "橱柜").id)
        other_parts = other_orders.map{|o| o.parts}.flatten
        indent_parts["other_orders_name"] = other_orders.pluck(:name)
        # 分别分组查询
        indent_parts["cupboard"]  = cupboard_parts.group_by{|p| [p.part_category_id, p.uom, p.brand]}
        indent_parts["others"]  = other_parts.group_by{|p| [p.part_category_id, p.uom, p.brand]}
        
        @result[indent.id] = indent_parts
      end
    end
    # 生成配件清单excel
    export_part_list(@result)
    render layout: false
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
                                                       :agent_id, :name, :status, :deleted, :customer,
                                                       :note, :is_use_order_material, :delivery_address, :_destroy],
                                   offers_attributes: [:id, :order_id, :item_id, :item_type, :item_name,
                                                       :uom, :number, :price, :note, :_destroy])
     # _return[:orders_attributes].each_pair{|k,v| v[:type] = Order.types[v[:type]] }
     # return _return
  end
end
