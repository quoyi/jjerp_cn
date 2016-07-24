class MaterialsController < ApplicationController
  before_action :set_material, only: [:show, :edit, :update, :destroy]

  # GET /materials
  # GET /materials.json
  def index
    @material = Material.new
    if params[:ply].present? && params[:texture].present? && params[:color].present?
      @materials = Material.where(ply: params[:ply], texture: params[:texture], color: params[:color]) 
    else
      @materials = Material.where(deleted: false)
    end
    respond_to do |format|
      format.html 
      format.json {render json: {flag: @materials.empty? ? "false" : "true"} }
    end
  end

  # GET /materials/1
  # GET /materials/1.json
  def show
  end

  # GET /materials/new
  def new
    @material = Material.new
  end

  # GET /materials/1/edit
  def edit
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
        format.html { redirect_to @material, notice: 'Material was successfully updated.' }
        format.json { render :show, status: :ok, location: @material }
      else
        format.html { render :edit }
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
