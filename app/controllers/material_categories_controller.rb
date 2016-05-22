class MaterialCategoriesController < ApplicationController
  before_action :set_material_category, only: [:destroy]

  # GET /material_categories
  # GET /material_categories.json
  def index
    @material_category = MaterialCategory.new
    @material_categories = MaterialCategory.where(deleted: false)
    @material_categories = MaterialCategory.where(oftype:  MaterialCategory.oftypes[params[:oftype]]) if params[:oftype].present?
  end

  # POST /material_categories
  # POST /material_categories.json
  def create
    @material_category = MaterialCategory.new(material_category_params)
    if @material_category.save
      redirect_to material_categories_path, notice: '板料类型创建成功！'
    else
      redirect_to material_categories_path, error: '请检查板料类型名称，创建失败！'
    end
  end

  # DELETE /material_categories/1
  # DELETE /material_categories/1.json
  def destroy
    @material_category.update_attributes(deleted: true)
    redirect_to material_categories_url, notice: '板料类型已删除！'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_material_category
    @material_category = MaterialCategory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def material_category_params
    params.require(:material_category).permit(:oftype, :name, :note, :deleted)
  end
end
