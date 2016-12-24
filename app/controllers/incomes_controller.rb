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
      @incomes = @incomes.where("income_at between ? and ?", params[:start_at], params[:end_at])
    end
    if params[:agent_id].present?
      @incomes = @incomes.where(agent_id: params[:agent_id])
    end
    if params[:bank_id].present?
      # 子订单号 order_id 和 总订单号 indent_id 为空时表示 代理商汇款； 不为空时表示 订单扣款
      @incomes = @incomes.where(bank_id: params[:bank_id])
    end
    @income = Income.new(bank_id: Bank.find_by(is_default: 1).try(:id), username: current_user.username, income_at: Time.now)

    @agent_incomes = @incomes.where("bank_id is not null and order_id is null and agent_id is not null").pluck(:money).sum
    @order_incomes = @incomes.where("bank_id is null and order_id is not null").pluck(:money).sum
    @other_incomes = @incomes.where(agent_id: nil).pluck(:money).sum
    respond_to do |format|
      format.html { @incomes = @incomes.page(params[:page]) }
      format.json
      format.xls {
        timestamp = Time.now.strftime("%Y%m%d%H%M%S%L")
        createIncomes(timestamp, @incomes)
        send_file "#{Rails.root}/public/excels/incomes/" + timestamp + ".xls", type: 'text/xls; charset=utf-8'
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
    Income.transaction do
      @income = Income.new(income_params)
if income_params[:bank_id].present?
      bank = Bank.find_by_id(income_params[:bank_id])
      bank.update!(balance: bank.balance + income_params[:money].to_f, incomes: bank.incomes + income_params[:money].to_f)
end
      if income_params[:reason] == "order"
        @income.reason = "订单收入"
        order = @income.order
        agent = @income.agent
        # 订单 “扣款”
        if income_params[:order_id].present?
          @income.note = "【#{Date.today.strftime("%Y-%m-%d")}】订单【#{order.name}】从余额扣除【#{income_params[:money]}元】"
          order.update!(arrear: order.arrear - income_params[:money].to_f)
          indent = order.indent
          indent.update!(arrear: indent.orders.pluck(:arrear).sum)
          agent.update!(balance: agent.balance - income_params[:money].to_f, arrear: agent.arrear - income_params[:money].to_f)
        else # “收入” 页面新建 收入记录（代理商打款）
          agent.update!(balance: agent.balance + income_params[:money].to_f)
        end
      else # 其他收入（例如卖废品收入等）
        @income.reason = "其他收入"
      end
      @income.save!
    end
    if @income.persisted?
      redirect_to :back, notice: '收入创建成功！'
    else
      redirect_to :back, error: '收入创建失败！'
    end
  end

  # PATCH/PUT /incomes/1
  # PATCH/PUT /incomes/1.json
  def update
    Income.transaction do
      origin_money = @income.money.to_f
      bank = Bank.find_by_id(income_params[:bank_id])
      bank.update!(balance: bank.balance + income_params[:money].to_f - origin_money,
                   incomes: bank.incomes + income_params[:money].to_f - origin_money)
      @income.update!(money: income_params[:money].presence.to_f)
      if income_params[:agent_id].present?
        agent = Agent.find_by_id(income_params[:agent_id])
        new_balance = agent.balance + income_params[:money].to_f - origin_money
        new_balance > 0 ? agent.update!(balance: new_balance) : agent.update!(arrear: agent.arrear + new_balance.abs)
      end
    end
    
    if @income.persisted?
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
      bank = @income.bank
      if @income.order
        order = @income.order
        indent = order.indent
        order.update!(arrear: order.arrear + @income.money)
        indent.update!(arrear: indent.arrear + @income.money)
      end
      
      if bank.balance >= @income.money
        bank.update!(balance: bank.balance - @income.money, incomes: bank.incomes - @income.money)
      else
        msg = {error: "银行卡余额不足，无法删除收入记录！"}
        raise ActiveRecord::Rollback
      end
      @income.destroy
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
