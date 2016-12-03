class CraftCategoriesController < ApplicationController
  before_action :set_craft_category, only: [:show, :edit, :update, :destroy]

  # GET /craft_categories
  # GET /craft_categories.json
  def index
    @craft_categories = CraftCategory.all
    @craft_category = CraftCategory.new
    if params[:start_at].present? && params[:end_at].present?
      @craft_categories = @craft_categories.where("created_at between ? and ?", params[:start_at], params[:end_at])
    end
  end

  # GET /craft_categories/1
  # GET /craft_categories/1.json
  def show
  end

  # GET /craft_categories/1
  # GET /craft_categories/1.json
  def find
    @craft_category = CraftCategory.find_by_id(params[:id]) if params[:id].present?
    respond_to do |format|
      format.json { render json: @craft_category}
    end
  end

  # GET /craft_categories/new
  def new
    @craft_category = CraftCategory.new
  end

  # GET /craft_categories/1/edit
  def edit
    render layout: false
  end

  # POST /craft_categories
  # POST /craft_categories.json
  def create
    @craft_category = CraftCategory.new(craft_category_params)

    respond_to do |format|
      if @craft_category.save
        format.html { redirect_to :back, notice: '工艺类型新建成功！' }
      else
        format.html { redirect_to :back, error: '工艺类型新建失败！' }
      end
    end
  end

  # PATCH/PUT /craft_categories/1
  # PATCH/PUT /craft_categories/1.json
  def update
    @craft_category.update_attributes(deleted: false) if craft_category_params[:reset].present? && craft_category_params[:reset]
    respond_to do |format|
      if @craft_category.update(craft_category_params)
        format.html { redirect_to :back, notice: '工艺类型编辑成功！' }
      else
        format.html { redirect_to :back, error: '工艺类型编辑失败！' }
      end
    end
  end

  # DELETE /craft_categories/1
  # DELETE /craft_categories/1.json
  def destroy
    @craft_category.update_attributes(deleted: true)
    respond_to do |format|
      format.html { redirect_to craft_categories_url, notice: '工艺类型已删除。' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_craft_category
      @craft_category = CraftCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def craft_category_params
      params.require(:craft_category).permit(:full_name, :uom, :price, :note, :deleted, :reset, 
                                             crafts_attributes: [:id, :order_id, :full_name, :uom, :craft_category_id,
                                                      :price, :number, :note, :status, :deleted, :_destroy])
    end
end
