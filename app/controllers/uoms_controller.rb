class UomsController < ApplicationController
  before_action :set_uom, only: [:show, :edit, :update, :destroy]

  # GET /uoms
  # GET /uoms.json
  def index
    @uoms = Uom.all
    @uom = Uom.new
  end

  # GET /uoms/1
  # GET /uoms/1.json
  def show
  end

  # GET /uoms/new
  def new
    @uom = Uom.new
  end

  # GET /uoms/1/edit
  def edit
    @uom = Uom.find_by_id(params[:id]) if params[:id].present?
    render layout: false
  end

  # POST /uoms
  # POST /uoms.json
  def create
    @uom = Uom.find_or_create_by(name: uom_params[:name])
    @uom.update_attributes(deleted: false) if @uom.deleted

    respond_to do |format|
      if @uom.save
        format.html { redirect_to uoms_path, notice: '单位新建成功！' }
      else
        format.html { redirect_to uoms_path, error: '单位新建失败！' }
      end
    end
  end

  # PATCH/PUT /uoms/1
  # PATCH/PUT /uoms/1.json
  def update
    #@uom.update_attributes(deleted: false) if params[:reset].present? && params[:reset]
    #@uom.update_attributes(name: params[:name]) if params[:name].present? && params[:name]
    if @uom.update(uom_params)
      redirect_to uoms_path, notice: '单位编辑成功！'
    else
      redirect_to uoms_path, error: '单位编辑失败！'
    end
  end

  # DELETE /uoms/1
  # DELETE /uoms/1.json
  def destroy
    @uom.update_attributes(deleted: true)
    # @uom.destroy
    respond_to do |format|
      format.html { redirect_to uoms_url, notice: '单位删除成功！' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_uom
      @uom = Uom.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def uom_params
      params.require(:uom).permit(:name, :val, :note, :deleted)
    end
end
