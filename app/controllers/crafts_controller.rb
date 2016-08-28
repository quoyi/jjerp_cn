class CraftsController < ApplicationController
  before_action :set_craft, only: [:show, :edit, :update, :destroy]

  # GET /crafts
  # GET /crafts.json
  def index
    @crafts = Craft.all
    @craft = Craft.new
  end

  # GET /crafts/1
  # GET /crafts/1.json
  def show
  end

  # GET /crafts/1
  # GET /crafts/1.json
  def find
    @craft = Craft.find_by_id(params[:id]) if params[:id].present?
    respond_to do |format|
      format.json { render json: @craft}
    end
  end

  # GET /crafts/new
  def new
    @craft = Craft.new
  end

  # GET /crafts/1/edit
  def edit
  end

  # POST /crafts
  # POST /crafts.json
  def create
    @craft = Craft.new(craft_params)

    respond_to do |format|
      if @craft.save
        format.html { redirect_to :back, notice: '工艺新建成功！' }
      else
        format.html { redirect_to :back, error: '工艺新建失败！' }
      end
    end
  end

  # PATCH/PUT /crafts/1
  # PATCH/PUT /crafts/1.json
  def update
    @craft.update_attributes(deleted: false) if craft_params[:reset].present? && craft_params[:reset]
    respond_to do |format|
      if @craft.update(craft_params)
        format.html { redirect_to :back, notice: '工艺编辑成功！' }
      else
        format.html { redirect_to :back, error: '工艺编辑失败！'  }
      end
    end
  end

  # DELETE /crafts/1
  # DELETE /crafts/1.json
  def destroy
    @craft.update_attributes(deleted: true)
    # @craft.destroy
    redirect_to crafts_path, notice: '工艺已删除。'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_craft
      @craft = Craft.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def craft_params
      params.require(:craft).permit(:order_id, :full_name, :note, :status, :price, :number, :deleted, :reset)
    end
end
