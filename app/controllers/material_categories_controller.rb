class MaterialCategoriesController < ApplicationController
  before_action :set_material_category, only: %i[show edit update destroy]

  # GET /material_categories
  # GET /material_categories.json
  def index
    @material_category = MaterialCategory.new
    @material_categories = MaterialCategory.all
    if params[:oftype].present?
      @material_categories = MaterialCategory.where(oftype: MaterialCategory.oftypes[params[:oftype]])
      @material_categories = @material_categories.where("name like '%#{params[:term]}%'") if params[:term].present?
    end
    respond_to do |format|
      format.html { @material_categories = @material_categories.page(params[:page]) }
      format.json do
        # @material_categories.where(oftype: MaterialCategory.oftypes[params[:type]]) if params[:type].present?
        if params[:page]
          per = 6
          size = @material_categories.offset((params[:page].to_i - 1) * per).size # 剩下的记录条数
          result = @material_categories.offset((params[:page].to_i - 1) * per).limit(per) # 当前显示的所有记录
          result = result.map { |mc| { id: mc.id, text: mc.name } }
          # result = result << {id: "", text: '全部'} if params[:page].to_i == 1
        end
        render json: { material_categories: result, total: size }
      end
    end
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

  # GET /material_categories/1/edit
  def edit
    @material_category = MaterialCategory.find_by_id(params[:id]) if params[:id].present?
    render layout: false
  end

  # PATCH/PUT /material_categories/1
  # PATCH/PUT /material_categories/1.json
  def update
    mc = MaterialCategory.find_by_id(params[:id])
    mc.update_attributes(deleted: false) if params[:reset].present? && params[:reset]
    if mc.update(material_category_params)
      redirect_to material_categories_path, notice: '板料类型编辑成功！'
    else
      redirect_to material_categories_path, error: '板料编辑失败！'
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
