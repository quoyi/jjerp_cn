class ExpendsController < ApplicationController
  before_action :set_expend, only: [:show, :edit, :update, :destroy]

  # GET /expends
  # GET /expends.json
  def index
    @expend = Expend.new
    @expends = Expend.where(deleted: false)
  end

  # GET /expends/1
  # GET /expends/1.json
  def show
  end

  # GET /expends/new
  def new
    @expend = Expend.new
  end

  # GET /expends/1/edit
  def edit
  end

  # POST /expends
  # POST /expends.json
  def create
    @expend = Expend.new(expend_params)
    if @expend.save
      redirect_to expends_path, notice: '支出记录创建成功！'
    else
      redirect_to expends_path, error: '支出记录创建失败！'
    end
  end

  # PATCH/PUT /expends/1
  # PATCH/PUT /expends/1.json
  def update
    if @expend.update(expend_params)
      redirect_to expends_path, notice: '支出记录编辑成功！'
    else
      redirect_to expends_path, error: '支出记录编辑失败！'
    end
  end

  # DELETE /expends/1
  # DELETE /expends/1.json
  def destroy
    @expend.update_attributes(deleted: true)
    redirect_to expends_path, notice: '支出记录已删除。'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expend
      @expend = Expend.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expend_params
      params.require(:expend).permit(:name, :reason, :money, :username, :expend_at, :status,
                                    :note, :bank_id, :deleted)
    end
end
