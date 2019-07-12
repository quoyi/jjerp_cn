class OrderCategoriesController < ApplicationController
  before_action :set_order_category, only: [:destroy]

  # GET /order_categories
  # GET /order_categories.json
  def index
    @order_category = OrderCategory.new
    @order_categories = OrderCategory.all
  end

  # POST /order_categories
  # POST /order_categories.json
  def create
    @order_category = OrderCategory.new(order_category_params)
    if @order_category.save
      redirect_to order_categories_path, notice: '订单类型创建成功！'
    else
      redirect_to order_categories_path, error: '请检查订单类型名称，创建失败！'
    end
  end

  # PATCH/PUT /part_categories/1
  # PATCH/PUT /part_categories/1.json
  def update
    oc = OrderCategory.find_by_id(params[:id])
    oc.update_attributes(deleted: false) if params[:reset].present? && params[:reset]
    redirect_to order_categories_path, notice: '订单类型编辑成功！'
  end

  # DELETE /order_categories/1
  # DELETE /order_categories/1.json
  def destroy
    @order_category.update_attributes(deleted: true)
    redirect_to order_categories_path, notice: '订单类型已删除！'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order_category
    @order_category = OrderCategory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_category_params
    params.require(:order_category).permit(:name, :note, :deleted)
  end
end
