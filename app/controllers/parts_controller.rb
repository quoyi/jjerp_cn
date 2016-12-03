class PartsController < ApplicationController
  before_action :set_part, only: [:show, :edit, :update, :destroy]

  # GET /parts
  # GET /parts.json
  def index
    @part = Part.new
    @parts = Part.where(deleted: false)
    @parts = Part.joins(:part_category).where(part_categories: {name: params[:name]}) if params[:name].present? && params[:name] != '所有'
    if params[:start_at].present? && params[:end_at].present?
      @parts = @parts.where("created_at between ? and ?", params[:start_at], params[:end_at])
    end

    # 配件统计信息
    parts_arr = []
    @parts.group_by{|p| p.part_category_id}.each_pair do |key, value|
      part_category = PartCategory.find_by(id: key)
      total_number = 0 
      value.each{|part| total_number += part.number}
      parts_arr << {name: part_category.name, number: total_number}
    end
    @parts_arr = parts_arr.sort_by{|m| m[:number] }
    @parts_arr = @parts_arr.reverse if params[:sort].present? && params[:sort] == 'desc'
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
                                :uom, :number, :brand, :note, :supply_id, :deleted)
  end
end
