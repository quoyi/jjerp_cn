class ExpendsController < ApplicationController
  include BanksHelper
  before_action :set_expend, only: %i[show edit update destroy]

  # GET /expends
  # GET /expends.json
  def index
    @expend = Expend.new(username: current_user.name, expend_at: Time.now)
    @expends = Expend.where(deleted: false).order(created_at: :desc)
    if params[:start_at].present? && params[:end_at].present?
      @expends = @expends.where('expend_at between ? and ?',
                                params[:start_at].to_datetime.beginning_of_day,
                                params[:end_at].to_datetime.end_of_day)
    end
    @expends = @expends.where(bank_id: params[:bank_id]) if params[:bank_id].present?

    respond_to do |format|
      format.html { @expends = @expends.page(params[:page]) }
      format.json
    end
  end

  # GET /expends/1
  # GET /expends/1.json
  def show
  end

  # GET /expends/new
  def new
    @expend = Expend.new(username: current_user.name, expend_at: Time.now)
  end

  # GET /expends/1/edit
  def edit
  end

  # POST /expends
  # POST /expends.json
  def create
    @expend = Expend.new(expend_params)
    if @expend.save
      # 修改银行卡的收入信息
      update_income_expend(expend_params, 1)
      redirect_to expends_path, notice: '支出记录创建成功！'
    else
      redirect_to expends_path, error: '支出记录创建失败！'
    end
  end

  # PATCH/PUT /expends/1
  # PATCH/PUT /expends/1.json
  def update
    if @expend.update(expend_params)
      # 修改银行卡的收入信息
      update_income_expend(expend_params, 1)
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
