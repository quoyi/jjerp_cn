class SuppliesController < ApplicationController
  before_action :set_supply, only: %i[show edit update destroy]

  # GET /supplies
  # GET /supplies.json
  def index
    @supply = Supply.new
    @supplies = Supply.where(deleted: false)

    respond_to do |format|
      format.html { @supplies = @supplies.page(params[:page]) }
    end
  end

  # GET /supplies/1
  # GET /supplies/1.json
  def show; end

  # GET /supplies/new
  def new
    @supply = Supply.new
  end

  # GET /supplies/1/edit
  def edit; end

  # POST /supplies
  # POST /supplies.json
  def create
    @supply = Supply.new(supply_params)
    if @supply.save
      redirect_to supplies_path, notice: '供应商创建成功！'
    else
      redirect_to supplies_path, error: '供应商创建失败！'
    end
  end

  # PATCH/PUT /supplies/1
  # PATCH/PUT /supplies/1.json
  def update
    @supply = Supply.new(supply_params)
    if @supply.update(supply_params)
      redirect_to supplies_path, notice: '供应商编辑成功！'
    else
      redirect_to supplies_path, notice: '供应商编辑失败！'
    end
  end

  # DELETE /supplies/1
  # DELETE /supplies/1.json
  def destroy
    @supply.update_attributes(deleted: true)
    redirect_to supplies_url, notice: '供应商已删除。'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_supply
    @supply = Supply.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def supply_params
    params.require(:supply).permit(:name, :full_name, :mobile, :bank_account, :address,
                                   :note, :deleted)
  end
end
