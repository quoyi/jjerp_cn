class IncomesController < ApplicationController
  include BanksHelper
  before_action :set_income, only: [:show, :edit, :update, :destroy]

  # GET /incomes
  # GET /incomes.json
  def index
    @incomes = Income.all
    if params[:indent_id].present? 
      indent = Indent.find(params[:indent_id])
      @incomes =@incomes.where(order_id: indent.orders.pluck(:id))
    end
    @incomes = @incomes.page(params[:page])
    @income = Income.new(bank_id: Bank.find_by(is_default: 1).try(:id), username: current_user.username, income_at: Time.now)
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
        # 在子订单上新增收入时
        if income_params[:order_id].present?
          # 更新总订单 欠款合计
          order = Order.find_by_id(income_params[:order_id])
          indent = order.indent
          agent = indent.agent
          agent_balance = agent.balance + income_params[:money].to_f
          # 修改银行卡的收入信息
          updateIncomeExpend(income_params, 0)
          # 从代理商余额扣除订单金额
          agent.orders.where("created_at >= ?", order.created_at).order(created_at: :asc).each do |o|
            next if o.income_status == '全款' || agent_balance <= 0
            o_arrear = o.arrear.to_f
            # 代理商余额足够时，扣除余额，新增订单收入记录；否则，扣除代理商余额、不足金额计算到订单欠款，跳出循环
            if agent_balance >= o_arrear
              agent_balance = agent_balance - o_arrear
              @income = o.incomes.new(indent_id: indent.id, bank_id: income_params[:bank_id], username: current_user.username,
                                      money: o_arrear, income_at: income_params[:income_at],
                                      note: income_params[:note])
                                      #"来自订单#{order.name}于#{income_params[:income_at]}收入的#{income_params[:money].to_i},剩余#{income_params[:money].to_i - o_arrear}已存入代理商余额")
              @income.save!
              # 更新子订单的欠款
              o.update!(arrear: 0)
            else
              # 代理商余额大于0时，新增扣款记录、不足金额计算到订单欠款
              if agent_balance > 0
                # 重复代码：跳出循环时，不执行本次循环break后面的代码
                @income = o.incomes.new(indent_id: indent.id, bank_id: income_params[:bank_id], money: agent_balance, 
                                     username: current_user.username, income_at: income_params[:income_at],
                                     note: income_params[:note])
                                     # "来自订单#{order.name}于#{income_params[:income_at]}收入的#{income_params[:money].to_i}")
                @income.save!
                # 更新子订单的欠款
                o.update!(arrear: o.arrear - agent_balance)
                agent_balance = 0
              else
                # 更新子订单的欠款
                o.update!(arrear: o.price)
              end
              # 直接跳出本层循环（不是本次！）
              break
            end
          end
          # 更新代理商余额、总订单的欠款
          # 代理商所有订单金额合计
          agent_orders_amount = agent.orders.pluck(:price).sum
          # 代理商所有订单的收入合计
          agent_orders_incomes = agent.orders.map{|o|o.incomes.pluck(:money)}.flatten.sum
          # 代理商金额差
          agent_orders_remain = agent_orders_amount - agent_orders_incomes
          if agent_orders_remain >= 0
            agent.update!(balance: agent_balance, arrear: agent_orders_remain)
          else
            agent.update!(balance: agent_balance + agent_orders_remain.abs)
          end
          indent.update!(arrear: indent.orders.pluck(:arrear).sum)
        else # 直接新建收入时
          @income = Income.new(income_params)
          @income.indent_id = @income.order.indent.id
          @income.save!
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
