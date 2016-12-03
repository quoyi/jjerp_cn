class BanksController < ApplicationController
  before_action :set_bank, only: [:show, :edit, :update, :destroy]

  # GET /banks
  # GET /banks.json
  def index
    @banks = Bank.all
    @bank = Bank.new
    respond_to do |format|
      format.html { @banks = @banks.page(params[:page]) }
    end
  end

  # GET /banks/1
  # GET /banks/1.json
  def show
  end

  # GET /banks/new
  def new
    @bank = Bank.new
  end

  # GET /banks/1/edit
  def edit
  end

  # POST /banks
  # POST /banks.json
  def create
    @bank = Bank.new(bank_params)

    if @bank.save
      redirect_to banks_path, notice: '银行卡新建成功！'
    else
      redirect_to banks_path, error: '银行卡新建失败！'
    end
  end

  # PATCH/PUT /banks/1
  # PATCH/PUT /banks/1.json
  def update
    if @bank.update(bank_params)
      redirect_to banks_path, notice: '银行卡编辑成功！'
    else
      redirect_to banks_path, error: '银行卡编辑失败！'
    end
  end

  # DELETE /banks/1
  # DELETE /banks/1.json
  def destroy
    # @bank.destroy
    redirect_to banks_path, notice: '银行卡已删除！'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_bank
    @bank = Bank.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bank_params
    params.require(:bank).permit(:name, :bank_name, :bank_card, :balance, :incomes, :expends, :is_default)
  end
end
