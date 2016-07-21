class PartsController < ApplicationController
  before_action :set_part, only: [:show, :edit, :update, :destroy]

  # GET /parts
  # GET /parts.json
  def index
    @part = Part.new
    @parts = Part.where(deleted: false)
    @parts = Part.joins(:part_category).where(part_categories: {name: params[:name]}) if params[:name].present? && params[:name] != '所有'
  end

  # GET /parts/new
  def new
    @part = Part.new
  end

  # GET /parts/1/edit
  def edit
  end

  # POST /parts
  # POST /parts.json
  def create
    @part = Part.new(part_params)
    if @part.save
      redirect_to :back, notice: '配件创建成功！'
    else
      redirect_to :back, error: '请检查配件名称，创建失败！'
    end
  end

  # PATCH/PUT /parts/1
  # PATCH/PUT /parts/1.json
  def update
    if @part.update(part_params)
      redirect_to parts_path, notice: '配件编辑成功！'
    else
      redirect_to parts_path, error: '配件编辑失败！'
    end
  end

  # DELETE /parts/1
  # DELETE /parts/1.json
  def destroy
    @part.update_attributes(deleted: true)
    redirect_to parts_path, notice: '配件已删除！'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_part
    @part = Part.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def part_params
    params.require(:part).permit(:part_category_id, :buy, :price, :store, :name,
                                :uom, :number, :brand, :supply_id, :deleted)
  end
end
