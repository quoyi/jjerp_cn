class IncomesController < ApplicationController
  include BanksHelper
  include IncomesHelper
  before_action :set_income, only: [:show, :edit, :update, :destroy]

  # GET /incomes
  # GET /incomes.json
  def index
    @incomes = Income.all.order(created_at: :desc)
    if params[:indent_id].present?
      indent = Indent.find_by_id(params[:indent_id])
      @incomes = @incomes.where(order_id: indent.orders.pluck(:id))
    end
    if params[:start_at].present? && params[:end_at].present?
      @incomes = @incomes.where('income_at between ? and ?', params[:start_at], params[:end_at])
    end
    if params[:agent_id].present?
      @incomes = @incomes.where(agent_id: params[:agent_id])
    end
    if params[:bank_id].present?
      # 子订单号 order_id 和 总订单号 indent_id 为空时表示 代理商汇款； 不为空时表示 订单扣款
      @incomes = @incomes.where(bank_id: params[:bank_id])
    end
    @income = Income.new(bank_id: Bank.find_by(is_default: 1).try(:id), username: current_user.username, income_at: Time.now)

    @agent_incomes = @incomes.where('bank_id is not null and order_id is null and agent_id is not null').pluck(:money).sum
    @order_incomes = @incomes.where('bank_id is null and order_id is not null').pluck(:money).sum
    @other_incomes = @incomes.where(agent_id: nil).pluck(:money).sum
    respond_to do |format|
      format.html { @incomes = @incomes.page(params[:page]) }
      format.json
      format.xls {
        timestamp = Time.now.strftime('%Y%m%d%H%M%S%L')
        createIncomes(timestamp, @incomes)
        send_file "#{Rails.root}/public/excels/incomes/" + timestamp + '.xls', type: 'text/xls; charset=utf-8'
      }
    end
  end

  # GET /incomes/1
  # GET /incomes/1.json
  def show
  end

  # GET /incomes/new
  def new
    @income = Income.new(bank_id: Bank.find_by(is_default: 1).id, username: current_user.username, income_at: Time.now)
  end

  # GET /incomes/1/edit
  def edit
    render layout: false
  end

  # POST /incomes
  # POST /incomes.json
  def create
    income = IncomeService.create_income(income_params)
    if income.persisted?
      redirect_to :back, notice: '收入创建成功！'
    else
      redirect_to :back, error: '收入创建失败！'
    end
  end

  # PATCH/PUT /incomes/1
  # PATCH/PUT /incomes/1.json
  def update
    income = IncomeService.update_income(@income, income_params)
    if income.persisted?
      redirect_to incomes_path, notice: '收入记录编辑成功！'
    else
      redirect_to incomes_path, error: '收入记录编辑失败！'
    end
  end

  # DELETE /incomes/1
  # DELETE /incomes/1.json
  def destroy
    msg = {notice: '收入记录已删除。'}
    Income.transaction do
      agent = @income.agent
      bank = @income.bank
      # 订单收入
      unless bank
        if @income.order
          order = @income.order
          indent = order.indent
          order.update!(arrear: order.arrear + @income.money)
          indent.update!(arrear: indent.arrear + @income.money)
          agent.update!(balance: agent.balance + @income.money)
        end
      else # 余额扣款
        if bank.balance >= @income.money && agent.balance >= @income.money
          bank.update!(balance: bank.balance.to_f - @income.money.to_f, incomes: bank.incomes.to_f - @income.money.to_f)
          agent.update!(balance: agent.balance.to_f - @income.money.to_f)
        else
          msg = {error: "银行卡或代理商余额不足，无法删除！"}
          raise ActiveRecord::Rollback
        end
      end
      # @income.destroy
      @income.update!(money: 0)
    end

    # @income.update(deleted: true)
    redirect_to incomes_path, msg
  end

  # 订单扣款
  def deduct
    order = Order.find_by_id(params[:order_id])
    @income = order.incomes.new(agent_id: order.agent_id, indent_id: order.indent.id)
    render layout: false
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
    elsif !params[:start_at].present? && !params[:end_at].present?
      beginning_month = Date.today.beginning_of_month
      end_month = Date.today.end_of_month
      @incomes = @incomes.where("income_at between ? and ?", beginning_month, end_month)
      @expends = @expends.where("expend_at between ? and ?", beginning_month, end_month)
    end

    if params[:bank_id].present?
      @incomes = @incomes.where(bank_id: params[:bank_id])
      @expends = @expends.where(bank_id: params[:bank_id])
    end

    @incomes = @incomes.order(income_at: :desc)
    @expends = @expends.order(expend_at: :desc)

    @incomes_expends = @incomes.to_a + @expends.to_a
    # @incomes_expends = @incomes_expends.page(params[:page])
    # respond_to do |format|
    #   format.html { @incomes_expends = @incomes_expends.page(params[:page]) }
    # end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_income
    @income = Income.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def income_params
    params.require(:income).permit(:name, :reason, :indent_id, :order_id, :money, :username,
                                   :income_at, :status, :note, :bank_id, :agent_id, :deleted)
  end
end
