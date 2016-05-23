class UnitsController < ApplicationController
  before_action :set_unit, only: [:show, :edit, :update, :destroy]

  # GET /units
  # GET /units.json
  def index
    @unit = Unit.new
    @units = Unit.all
  end

  # GET /units/1
  # GET /units/1.json
  def show
  end

  # GET /units/new
  def new
    @unit = Unit.new
  end

  # GET /units/1/edit
  def edit
  end

  # POST /units
  # POST /units.json
  def create
    @unit = Unit.new(unit_params)
    binding.pry
    if @unit.save!
      redirect_to units_path, notice: '部件创建成功！'
    else
      redirect_to units_path, error: '部件创建失败！'
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    if @unit.update(unit_params)
      redirect_to units_path, notice: '部件编辑成功！'
    else
      redirect_to units_path, error: '部件编辑失败！'
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @unit.destroy
    redirect_to units_url, notice: '部件已删除。'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_unit
    @unit = Unit.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def unit_params
    params.require(:unit).permit(:id, :unit_category_id, :order_id, :name, :full_name,
                                :material_id,:ply, :texture, :color, :length, :width, :supply_id,
                                :number, :uom, :price, :size, :note, :edge, :customer, :out_edge_thick,
                                :in_edge_thick, :back_texture, :door_type, :door_mould, :door_handle_type,
                                :door_edge_type, :door_edge_thick, :task, :state, :craft, :deleted)
  end
end
