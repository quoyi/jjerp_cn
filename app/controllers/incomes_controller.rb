class IncomesController < ApplicationController
  before_action :set_income, only: [:show, :edit, :update, :destroy]

  # GET /incomes
  # GET /incomes.json
  def index
    @income = Income.new
    @incomes = Income.where(deleted: false)
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
      redirect_to incomes_path, notice: '收入记录创建成功！'
    else
      redirect_to incomes_path, error: '收入记录创建失败！'
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_income
      @income = Income.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def income_params
      params.require(:income).permit(:name, :reason, :indent_id, :money, :username, :income_at,
                                    :status, :note, :deleted)
    end
end
