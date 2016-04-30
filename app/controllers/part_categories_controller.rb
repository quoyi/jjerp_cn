class PartCategoriesController < ApplicationController
  before_action :set_part_category, only: [:destroy]

  # GET /part_categories
  # GET /part_categories.json
  def index
    @part_category = PartCategory.new
    @part_categories = PartCategory.all
  end

  # POST /part_categories
  # POST /part_categories.json
  def create
    @part_category = PartCategory.new(part_category_params)
    if @part_category.save
      msg = '配件类型创建成功！'
    else
      msg = '请检查配件类型名称，创建失败！'
    end
    redirect_to part_categories_path, notice: msg
  end

  # DELETE /part_categories/1
  # DELETE /part_categories/1.json
  def destroy
    @part_category.destroy
    redirect_to part_categories_path, notice: '配件类型已删除！'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_part_category
      @part_category = PartCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def part_category_params
      params.require(:part_category).permit(:name, :note)
    end
end
