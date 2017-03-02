class IncomeService < BaseService
  # 创建收入
  def self.create_income(income_params)
    income = Income.new(income_params)
    money = income_params[:money].to_f
    # 新建订单收入
    if income_params[:bank_id].present?
      bank = Bank.find_by_id(income_params[:bank_id])
      bank.update!(balance: bank.balance.to_f + money,
                   incomes: bank.incomes.to_f + money)
      if income_params[:agent_id].present?
        income.reason = '订单收入'
        income.note = income.note.presence || "【#{Date.today.strftime('%Y-%m-%d')}】手工添加收入【#{money}元】"
        agent = income.agent
        agent.update(balance: agent.balance + money)
      else
        income.reason = '其他收入'
        income.note = income.note.presence || "【#{Date.today.strftime('%Y-%m-%d')}】手工添加收入【#{money}元】"
      end
    # 订单(代理商余额)扣款
    elsif income_params[:agent_id].present? && income_params[:order_id].present?
      order = income.order
      indent = order.indent
      agent = income.agent
      income.reason = '余额扣款'
      income.indent_id = order.indent.id
      income.note = income.note.presence || "【#{Date.today.strftime('%Y-%m-%d')}】订单【#{order.name}】从【#{agent.full_name}】余额扣除【#{money}元】"
      order.update(arrear: order.arrear - money)
      indent.update(arrear: indent.arrear - money)
      agent.update(balance: agent.balance - money, arrear: agent.arrear + money)
    end
    income.save
    income
  end

  def self.update_income(income, income_params)
    # 修改前后的金额差
    income_remain = income.money - income_params[:money].to_f
    # 修改的收入为：代理商打款（有银行信息时）
    if income_params[:bank_id].present?
      bank = income.bank
      bank.update!(balance: bank.balance - income_remain,
                   incomes: bank.incomes - income_remain)
      if income_params[:agent_id].present?
        agent = income.agent
        agent.update(balance: agent.balance - income_remain)
      end
    elsif income_params[:agent_id].present? && income_params[:order_id].present?
      order = income.order
      indent = order.indent
      agent = income.agent
      order.update(arrear: order.arrear - income_remain)
      indent.update(arrear: indent.arrear - income_remain)
      agent.update(balance: agent.balance - income_remain)
    end

    income_params[:note] = if income_params[:note].present?
                             income_params[:note] + ";【#{Date.today.strftime('%Y-%m-%d')}】将【#{income.money}元】修改为【#{income_params[:money]}元】"
                           else
                             "【#{Date.today.strftime('%Y-%m-%d')}】将【#{income.money}元】修改为【#{income_params[:money]}元】"
                           end
    income.update(income_params)
    income
  end
end
