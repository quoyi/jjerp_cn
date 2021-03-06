class MaterialsController < ApplicationController
  before_action :set_material, only: %i[show edit update destroy]

  # GET /materials
  # GET /materials.json
  def index
    @material = Material.new
    @materials = Material.where(deleted: false)
    if params[:start_at].present? && params[:end_at].present?
      @materials = @materials.where('created_at between ? and ?',
                                    params[:start_at].to_datetime.beginning_of_day,
                                    params[:end_at].to_datetime.end_of_day)
    end

    # 板料统计信息 (全部 / 所选时间段)
    materials_arr = []
    Unit.all.group_by { |u| [u.ply, u.texture, u.color] }.each_pair do |key, value|
      obj = {}
      materail = Material.find_by(ply: key.first, texture: key.second, color: key.last)
      total_number = 0
      value.each do |unit|
        if unit.is_custom
          total_number += unit.number.to_f
        else
          size = unit.size.split(/[xX*×]/).map(&:to_i)
          total_number += size.length > 1 ? ((unit.number.to_f * size[0] * size[1]) / (1000 * 1000)) : unit.number.to_f
        end
      end
      obj[:name] = materail.try(:full_name)
      obj[:number] = total_number
      materials_arr << obj
    end
    @materials_arr = materials_arr.sort_by { |m| m[:number] }
    @materials_arr = @materials_arr.reverse if params[:sort].present? && params[:sort] == 'desc'
    respond_to do |format|
      format.html { @materials = @materials.page(params[:page]) }
      format.json { render json: { flag: @materials.empty? ? 'false' : 'true' } }
    end
  end

  # GET /materials/1
  # GET /materials/1.json
  def show
  end

  # POST /materials/condition
  # POST /materials.json
  def find
    @material = Material.where(ply: params[:ply], texture: params[:texture], color: params[:color]).first
    @material = Material.where(ply: params[:ply], texture: params[:texture]).first unless @material.present?
    @material = Material.where(ply: params[:ply], color: params[:color]).first unless @material.present?
    @material = Material.where(texture: params[:texture], color: params[:color]).first unless @material.present?
    @material = Material.where(ply: params[:ply]) unless @material.present?
    @material = Material.where(texture: params[:texture]) unless @material.present?
    @material = Material.where(color: params[:color]) unless @material.present?
    respond_to do |format|
      format.json { render json: @material }
    end
  end

  # GET /materials/new
  def new
    @material = Material.new
  end

  # GET /materials/1/edit
  def edit
    render layout: false
  end

  # POST /materials
  # POST /materials.json
  def create
    @material = Material.new(material_params)
    if @material.save
      redirect_to :back, notice: '板料创建成功！'
    else
      redirect_to :back, error: '板料创建失败！'
    end
  end

  # PATCH/PUT /materials/1
  # PATCH/PUT /materials/1.json
  def update
    respond_to do |format|
      if @material.update(material_params)
        format.html { redirect_to materials_path, notice: "板料 #{@material.full_name} 更新成功！" }
        format.json { render :show, status: :ok, location: @material }
      else
        format.html { render :back, error: '板料编辑失败！' }
        format.json { render json: @material.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /materials/1
  # DELETE /materials/1.json
  def destroy
    @material.update_attributes(deleted: true)
    redirect_to materials_url, notice: '板料已删除。'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_material
    @material = Material.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def material_params
    params.require(:material).permit(:name, :full_name, :ply, :texture, :color, :store, :buy,
                                     :price, :uom, :supply_id, :deleted)
  end
end
