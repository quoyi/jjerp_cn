class UnitCategoriesController < ApplicationController
  before_action :set_unit_category, only: [:destroy]

  # GET /unit_categories
  # GET /unit_categories.json
  def index
    @unit_category = UnitCategory.new
    @unit_categories = UnitCategory.all

    respond_to do |format|
      format.html { @unit_categories = @unit_categories.page(params[:page]) }
    end
  end

  # POST /unit_categories
  # POST /unit_categories.json
  def create
    @unit_category = UnitCategory.new(unit_category_params)
    if @unit_category.save
      redirect_to unit_categories_path, notice: '部件类型创建成功！'
    else
      redirect_to unit_categories_path, error: '请检查部件类型名称，创建失败！'
    end
  end

  # PATCH/PUT /part_categories/1
  # PATCH/PUT /part_categories/1.json
  def update
    uc = UnitCategory.find_by_id(params[:id])
    uc.update_attributes(deleted: false) if params[:reset].present? && params[:reset]
    redirect_to unit_categories_path, notice: '部件类型编辑成功！'
  end

  # DELETE /unit_categories/1
  # DELETE /unit_categories/1.json
  def destroy
    @unit_category.update_attributes(deleted: true)
    redirect_to unit_categories_path, notice: '部件类型已删除！'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_unit_category
    @unit_category = UnitCategory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def unit_category_params
    params.require(:unit_category).permit(:name, :note, :deleted)
  end
end
