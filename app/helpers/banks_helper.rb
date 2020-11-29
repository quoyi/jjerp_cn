module BanksHelper
  # 更新银行卡信息
  #   bank_id  银行卡号
  #   money 收入或者支出金额
  #   type 'income'.收入   'expend'.支出
  def update_income_expend(bank_id, money, type)
    bank = Bank.find_by_id(bank_id)
    # 添加支出时，需要增、减余额
    case type
    when 'income'
      bank.update!(balance: bank.balance - money, expends: bank.expends + money)
      # bank.expends += money
      # bank.balance -= money
    when 'expend'
      # bank.incomes += money
      # bank.balance += money
      bank.update!(balance: bank.balance + money, incomes: bank.incomes + money)
      # else
      # 其他情况，暂时不处理
    end
    # bank.save!
  end
end
