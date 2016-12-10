class IncomesController < ApplicationController
  include BanksHelper
  before_action :set_income, only: [:show, :edit, :update, :destroy]

  # GET /incomes
  # GET /incomes.json
  def index
    @incomes = Income.all
    if params[:indent_id].present?
      indent = Indent.find_by_id(params[:indent_id])
      @incomes = @incomes.where(order_id: indent.orders.pluck(:id))
    end
    if params[:start_at].present? && params[:end_at].present?
      @incomes = @incomes.where("income_at between ? and ?", params[:start_at], params[:end_at])
    end
    if params[:agent_id].present?
      agent = Agent.find_by_id(params[:agent_id])
      @incomes = @incomes.where(order_id: agent.orders.pluck(:id))
    end
    @income = Income.new(bank_id: Bank.find_by(is_default: 1).try(:id), username: current_user.username, income_at: Time.now)

    respond_to do |format|
      format.html { @incomes = @incomes.page(params[:page]) }
      format.json
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
  end

  # POST /incomes
  # POST /incomes.json
  def create
    begin
      Income.transaction do
        binding.pry
        # 子订单收入
        if income_params[:order_id].present?
          # 指定子订单号时，需要将收入金额添加到代理商，然后从代理商余额中扣除子订单金额
          if income_params[:order_id].to_i > 0
            order = Order.find_by_id(income_params[:order_id])
            indent = order.indent
            agent = indent.agent
            # 收入金额加到代理商余额中
            agent_balance = agent.balance + income_params[:money].to_f
            agent_arrear = agent.arrear - income_params[:money].to_f
            # 新建银行卡的收入信息
            updateIncomeExpend(income_params[:bank_id], income_params[:money].to_f, 'income')
            @income = order.incomes.new(indent_id: order.indent.id, bank_id: income_params[:bank_id], username: income_params[:username],
                                       money: income_params[:money], income_at: income_params[:income_at], note: income_params[:note], reason: order.name)
            @income.save!
            # 如果订单欠款大于收入，则继续欠款；否则，欠款为零
            if order.arrear > agent.balance
              order.update!(arrear: order.arrear - agent_balance)
              agent.update!(balance: 0, arrear: agent_arrear)
            else
              order.update!(arrear: 0)
              agent.update!(balance: agent_balance - order.arrear, arrear: agent_arrear)
            end
          else # 子订单号为0 或为指定时，视为其他收入
            @income = Income.new(bank_id: income_params[:bank_id], username: income_params[:username], money: income_params[:money],
                                income_at: income_params[:income_at], note: income_params[:note], reason: '其他收入')
            @income.save!
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => exception
    end
    
    
    if @income
      redirect_to :back, notice: '收入记录创建成功！'
    else
      redirect_to :back, error: '收入记录创建失败！'
    end
  end

  # PATCH/PUT /incomes/1
  # PATCH/PUT /incomes/1.json
  def update
    if @income.update(income_params)
      # 修改银行卡的收入信息
      updateIncomeExpend(income_params, 0)
      redirect_to incomes_path, notice: '收入记录编辑成功！'
    else
      redirect_to incomes_path, error: '收入记录编辑失败！'
    end
  end

  # DELETE /incomes/1
  # DELETE /incomes/1.json
  def destroy
    Income.transaction do 
      order = @income.order
      indent = @income.indent
      bank = @income.bank
      order.update!(arrear: order.arrear + @income.money)
      indent.update!(arrear: indent.arrear + @income.money)
      if bank.balance > @income.money
        bank.update!(balance: bank.balance - @income.money, incomes: bank.incomes - @income.money)
      else
        msg = "银行卡余额不足，无法删除收入记录！"
        raise ActiveRecord::Rollback
      end
      @income.destroy
      msg = '收入记录已删除。'
    end

    # @income.update(deleted: true)
    redirect_to incomes_path, notice: msg
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
                                     :income_at, :status, :note, :bank_id, :deleted)
    end
end
