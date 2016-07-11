class IncomesController < ApplicationController
  before_action :set_income, only: [:show, :edit, :update, :destroy]

  # GET /incomes
  # GET /incomes.json
  def index
    @income = Income.new
    @incomes = params[:indent_id].present? ? Income.where(indent_id: params[:indent_id]) : Income.all
  end

  # GET /incomes/1
  # GET /incomes/1.json
  def show
  end

  # GET /incomes/new
  def new
    @income = Income.new
  end

  # GET /incomes/1/edit
  def edit
  end

  # POST /incomes
  # POST /incomes.json
  def create
    @income = Income.new(income_params)
    if @income.save
      redirect_to :back, notice: '收入记录创建成功！'
    else
      redirect_to :back, error: '收入记录创建失败！'
    end
  end

  # PATCH/PUT /incomes/1
  # PATCH/PUT /incomes/1.json
  def update
    if @income.update(income_params)
      redirect_to incomes_path, notice: '收入记录编辑成功！'
    else
      redirect_to incomes_path, error: '收入记录编辑失败！'
    end
  end

  # DELETE /incomes/1
  # DELETE /incomes/1.json
  def destroy
    @income.destroy
    redirect_to incomes_path, notice: '收入记录已删除。'
  end


  def stat
    @incomes = Income.all
    @expends = Expend.all

    if params[:start_at].present? && params[:end_at].present?
      @incomes = @incomes.where("income_at between ? and ?", params[:start_at], params[:end_at])
      @expends = @expends.where("expend_at between ? and ?", params[:start_at], params[:end_at])
    elsif params[:start_at].present? || params[:end_at].present?
      @incomes = @incomes.where("income_at = ? ", params[:start_at].present? ? params[:start_at] : params[:end_at])
      @expends = @expends.where("expend_at = ? ", params[:start_at].present? ? params[:start_at] : params[:end_at])
    end

    if params[:bank_id].present?
      @incomes = @incomes.where(bank_id: params[:bank_id])
      @expends = @expends.where(bank_id: params[:bank_id])
    end

    @incomes = @incomes.order(income_at: :desc)
    @expends = @expends.order(expend_at: :desc)

    @incomes_expends = @incomes.to_a + @expends.to_a

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_income
      @income = Income.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def income_params
      params.require(:income).permit(:name, :reason, :indent_id, :money, :username, :income_at,
                                    :status, :note, :bank_id, :deleted)
    end
end
