class OrdersController < ApplicationController
  include OrdersHelper
  before_action :set_order, only: [:show, :edit, :update, :destroy, :import]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.where(deleted:false)
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    # 这里可能需要修改, 应查找unit_category并获取ID值，再查找对应的material；而不是写固定值“1”
    @materials = Unit.where(order_id: @order.id, unit_category_id: 1)
    @parts = Unit.where(order_id: @order_id, unit_category_id: 2)
    @crafts = Unit.where(order_id: @order_id, unit_category_id: 3)
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

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    # 需要标记删除，不能真正地删除
    @order.update_attributes(deleted: true)
    redirect_to orders_url, notice: '子订单已删除。'
  end

  # 导入文件，或手工输入
  def import
    msg = import_order_units(params[:file], @order.name)
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

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:indent_id, :name, :order_category_id, :ply, :texture,
                                  :color, :length, :width, :height, :number, :price,
                                  :status, :note, :deleted, :file, :_destroy,
                                  units_attributes: [],
                                  parts_attributes: [],
                                  crafts_attributes: [])
  end
end
