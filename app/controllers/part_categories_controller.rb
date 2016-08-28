class PartCategoriesController < ApplicationController
  before_action :set_part_category, only: [:destroy]

  # GET /part_categories
  # GET /part_categories.json
  def index
    @part_category = PartCategory.new
    @part_categories = PartCategory.order(parent_id: :asc)
    @part_categories = PartCategory.where(parent_id: params[:id]).order(created_at: :desc) if params[:id].present?
  end

  # POST /part_categories/find.json
  def find
    @part_categories = PartCategory.where(parent_id: params[:parent_id], deleted: false) if params[:parent_id].present?
    # 通用性问题（view 中使用了 each，遍历单条记录时会报错），此处必须用where 
    @part_categories = PartCategory.where(id: params[:id]) if params[:id].present?
    respond_to do |format|
      format.json { render json: @part_categories}
    end
  end

  # POST /part_categories
  # POST /part_categories.json
  def create
    # 检查新建配件类型是否已存在
    @part_category = PartCategory.find_by(parent_id: part_category_params[:parent_id], name: part_category_params[:name])
    if @part_category.present?
      # 配件类型已存在，且被删除时，恢复使用(不需要重新创建)
      @part_category.update_attributes(deleted: false) if @part_category.deleted
      redirect_to :back, notice: '配件类型创建成功！'
    else
      # 配件类型不存在时，新建
      @part_category = PartCategory.new(part_category_params)
      if @part_category.save
        redirect_to :back, notice: '配件类型创建成功！'
      else
        redirect_to :back, error: '请检查配件类型名称，创建失败！'
      end
    end
  end

  # GET /part_categories/1
  # GET /part_categories/1.json
  def edit
  end

  # PATCH/PUT /part_categories/1
  # PATCH/PUT /part_categories/1.json
  def update
    pc = PartCategory.find_by_id(params[:id])
    pc.update_attributes(deleted: false) if params[:reset].present? && params[:reset]
    pc.update_attributes(name: params[:name]) if params[:name].present?
    respond_to do |format|
      format.html { redirect_to part_categories_path, notice: '配件类型编辑成功！' }
      format.json { render json: pc}
    end
  end

  # DELETE /part_categories/1
  # DELETE /part_categories/1.json
  def destroy
    @part_category.update_attributes(deleted: true)
    # 当配件类型为“基本类型”时，需要将它的所有子类型都标记删除
    PartCategory.where(parent_id: @part_category.id).update_all(deleted: true) if @part_category.parent_id == 0
    redirect_to part_categories_path, notice: '配件类型已删除！'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_part_category
      @part_category = PartCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def part_category_params
      params.require(:part_category).permit(:id, :parent_id, :name, :buy, :price, :store,
                                            :uom, :brand, :supply_id, :note, :deleted)
    end
end
