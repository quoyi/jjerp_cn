class OrdersController < ApplicationController
  include OrdersHelper
  include OffersHelper
  before_action :set_order, only: [:show, :edit, :update, :destroy, :import, :custom_offer]

  # GET /orders
  # GET /orders.json
  def index
    @unit = Unit.new
    @part = Part.new
    @craft = Craft.new
    @order = Order.new
    @orders = Order.where.not(status: Order.statuses[:sent]).order(created_at: :desc)
    # 判断搜索条件 起始时间 -- 结束时间
    if params[:start_at].present? && params[:end_at].present?
      @orders = @orders.joins(:indent).where("indents.verify_at between ? and ?", params[:start_at], params[:end_at])
    elsif params[:start_at].present? || params[:end_at].present?
      @orders = @orders.joins(:indent).where("indents.verify_at = ? ", params[:start_at].present? ? params[:start_at] : params[:end_at])
    end
    # 搜索条件 代理商ID
    @orders = @orders.joins(:indent).where("indents.agent_id = ?",params[:agent_id]) if params[:agent_id].present?

    respond_to do |format|
      format.html 
      format.xls do
        export_orders(@orders, params[:start_at], params[:end_at])
        send_file "#{Rails.root}/public/excels/orders.xls", type: 'text/xls; charset=utf-8'
      end
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @unit = Unit.new
    @material = Material.new
    @part_category = PartCategory.new
    # 这里可能需要修改, 应查找unit_category并获取ID值，再查找对应的material；而不是写固定值“1”
    @units = Unit.where(order_id: @order.id)
    @parts = Part.where(order_id: @order.id)
    @crafts = Craft.where(order_id: @order.id)
    @indent = @order.indent
    @agent = @indent.agent
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    if @order.save
      # 订单保存后，更新订单、子订单的价格合计
      update_order_and_indent(@order)
      create_offer(@order.indent)
      redirect_to :back, notice: '子订单创建成功！'
    else
      redirect_to :back, error: '子订单创建失败！'
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    return redirect_to @order, error: '请求无效！请检查数据是否有效。' unless params[:order]
    if @order.update(order_params)
      # 订单更新后，更新订单、子订单的价格合计
      update_order_and_indent(@order)
      create_offer(@order.indent)
      redirect_to @order.indent, notice: '子订单编辑成功！'
    else
      redirect_to @order, error: '子订单编辑失败！请仔细检查后再提交。'
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    redirect_to orders_url, notice: '子订单已删除。'
  end

  #生产任务
  def producing
    @orders = Order.producing
  end

  # 导入文件，或手工输入
  def import
    msg = import_order_units(params[:file], @order.name)
    # 订单修改后，更新订单、子订单的价格合计
    update_order_and_indent(@order)
    create_offer(@order.indent)
    return redirect_to order_path(@order), notice: msg
    # 有上传文件时
    # if params[:file].original_filename !~ /.csv$/
    #   return redirect_to order_path(@order), error: '文件格式不正确！'
    # else
    #   msg = import_order_units(params[:file], @order.name)
    #   if msg == "success"
    #     return redirect_to order_path(@order), notice: "拆单导入成功"
    #   else
    #     return redirect_to order_path(@order), alert: msg
    #   end
    # end
  end

  def custom_offer
    @indent = @order.indent
    @unit = Unit.new
    @material = Material.new
    @part_category = PartCategory.new   
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:indent_id, :name, :order_category_id, :ply, :texture,
                                  :color, :length, :width, :height, :number, :price,
                                  :status, :oftype, :note, :deleted, :file, :_destroy,
                                  units_attributes: [:id, :full_name, :number, :ply,:texture,:color,
                                                     :length, :width, :size, :uom, :price, :note, :_destroy],
                                  parts_attributes: [:id, :part_category_id, :order_id,
                                                     :name, :buy, :price, :store, :uom, :number, :brand,
                                                     :supply_id, :deleted, :_destroy],
                                  crafts_attributes: [:id, :order_id, :full_name, :uom,
                                                      :price, :number, :note, :status, :deleted, :_destroy])
  end
end
