class IncomesController < ApplicationController
  include BanksHelper
  include IncomesHelper
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
    if params[:bank_id].present?
      @incomes = @incomes.where(bank_id: params[:bank_id])
    end

    @income = Income.new(bank_id: Bank.find_by(is_default: 1).try(:id), username: current_user.username, income_at: Time.now)

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
    # binding.pry
    @income = Income.new(bank_id: Bank.find_by(is_default: 1).id, username: current_user.username, income_at: Time.now)
  end

  # GET /incomes/1/edit
  def edit
  end

  # POST /incomes
  # POST /incomes.json
  def create
    msg = {notice: '创建成功！'}
    Income.transaction do
      bank = Bank.find_by_id(income_params[:bank_id])
      bank.update!(incomes: bank.incomes + income_params[:money].to_f)
      if params[:reason] == "order"
        return redirect_to :back, error: '类型为“订单收入”时必须指定订单号！' unless params[:order_name].present?
        order = Order.where("name like '#{params[:date][:year]}%#{params[:date][:month]}%#{params[:order_name]}%'").first
        indent = order.indent
        agent = indent.agent
        @income = Income.new(income_params)
        @income.indent_id = indent.id
        @income.agent_id = agent.id
        @income.reason = order.name
        @income.note = income_params[:note]
        @income.save!
        agent.update!(balance: agent.balance + income_params[:money].to_f)

        income = order.incomes.new(income_params)
        income.indent_id = indent.id
        income.agent_id = agent.id
        # 如果订单欠款 大于 代理商余额，则继续欠款；否则，欠款为零(注意更新顺序不可改变，否则数据变化)
        if order.arrear >= agent.balance
          income.reason = order.name,
          income.money = agent.balance
          income.note = "在#{income_params[:income_at]}订单【#{order.name}】收入【#{agent.balance}】元。"
          income.save!
          order.update!(arrear: order.arrear - agent.balance)
          agent.update!(balance: 0, arrear: agent.arrear - income_params[:money].to_f)
        else
          income.reason = '其他收入'
          income.money = order.arrear
          income.save!
          agent.update!(balance: agent.balance - order.arrear, arrear: agent.arrear - order.arrear)
          order.update!(arrear: 0)
        end
        indent.update!(arrear: indent.orders.pluck(:arrear).sum)
        msg = {notice: "成功创建订单#{order.name}收入！"}
      elsif params[:reason] == "other"
        binding.pry
        # income_params[:reason] = 
        @income = Income.new(income_params)
        @income.reason ='其他收入'
        @income.save!
        msg = {notice: '成功创建其他收入！'}
      else
        # 既不是“订单收入”，也不是“其他收入”
        msg = {error: '创建失败！必须指定收入类型！'}
      end
    end
    
    #TODO: 逻辑未整理完

    #     # 子订单收入
    #     if income_params[:order_id].present?
    #       # 指定子订单号时，需要将收入金额添加到代理商，然后从代理商余额中扣除子订单金额
    #       if income_params[:order_id].to_i > 0
    #         order = Order.find_by_id(income_params[:order_id])
    #         indent = order.indent
    #         agent = indent.agent
    #         # 收入金额加到代理商余额中
    #         agent_balance = agent.balance + income_params[:money].to_f
    #         agent_arrear = agent.arrear - income_params[:money].to_f
    #         # 如果订单欠款 大于 代理商余额，则继续欠款；否则，欠款为零(注意更新顺序不可改变，否则数据变化)
    #         if order.arrear > agent_balance
    #           # 界面新增收入记录
    #           @income = order.incomes.new(indent_id: indent.id, bank_id: income_params[:bank_id], username: income_params[:username], agent_id: agent.id,
    #                                       money: income_params[:money], income_at: income_params[:income_at], note: income_params[:note], reason: order.name)
    #           @income.save!
    #           # 从代理商余额扣除金额，也要记录下来
    #           income = order.incomes.new(indent_id: indent.id, bank_id: income_params[:bank_id], username: income_params[:username], agent_id: agent.id, 
    #                                      money: agent.balance, income_at: income_params[:income_at], note: "从代理商#{agent.full_name}余额中扣除【#{agent.balance}】元。")
    #           income.save!
    #           order.update!(arrear: order.arrear - agent_balance)
    #           indent.update!(arrear: indent.arrear - agent_balance)
    #           agent.update!(balance: 0, arrear: agent_arrear)
    #         else
    #           @income = order.incomes.new(indent_id: indent.id, bank_id: income_params[:bank_id], username: income_params[:username], agent_id: agent.id,
    #                                       money: order.arrear, income_at: income_params[:income_at], note: income_params[:note], reason: order.name)
    #           @income.save!
    #           if order.arrear == agent_balance
    #             reason = "余额扣除"
    #             note = "新增收入#{income_params[:money]}与代理商余额之和，正好足够订单【#{order.name}】扣除欠款。"
    #           else
    #             reason = "订单结余"
    #             note = "【#{income_params[:income_at]}】收入【#{income_params[:money]}元】，扣除订单【#{order.name}】欠款后剩余【#{agent_balance-order.arrear}元】存入代理商【#{agent.full_name}】余额中。"
    #           end
    #           # 多余的钱新建一条收入记录，不关联订单号
    #           income = Income.new(bank_id: income_params[:bank_id], username: income_params[:username], agent_id: agent.id,
    #                               money: agent_balance - order.arrear, income_at: income_params[:income_at], reason: reason,
    #                               note: note)
    #           income.save!
    #           agent.update!(balance: agent_balance - order.arrear, arrear: 0)
    #           indent.update!(arrear: 0)
    #           order.update!(arrear: 0)
    #         end
    #         # 新建银行卡的收入信息
    #         updateIncomeExpend(income_params[:bank_id], income_params[:money].to_f, 'income')
    #       else # 子订单号为0 或为指定时，视为其他收入
    #         @income = Income.new(bank_id: income_params[:bank_id], username: income_params[:username], money: income_params[:money], agent_id: agent.id,
    #                             income_at: income_params[:income_at], note: income_params[:note], reason: '其他收入')
    #         @income.save!
    #       end
    #     end
    #   end
    # rescue ActiveRecord::RecordInvalid => exception
    # end
    
    if @income.persisted?
      redirect_to :back, msg
    else
      redirect_to :back, msg
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
    msg = {notice: '收入记录已删除。'}
    Income.transaction do
      bank = @income.bank
      if @income.order
        order = @income.order
        indent = order.indent
        order.update!(arrear: order.arrear + @income.money)
        indent.update!(arrear: indent.arrear + @income.money)
      end
      
      binding.pry
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
