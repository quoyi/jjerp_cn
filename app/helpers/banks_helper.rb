module BanksHelper

  # 更新银行卡信息
  #   income_expend 收入或者支出记录
  #   type 0.收入   1.支出
  def updateIncomeExpend(income_expend, type)
    bank = Bank.find_by_id(income_expend[:bank_id])
    money = income_expend[:money].to_f
    # 添加支出时，需要增、减余额
    if type == 1
      bank.update!(balance: bank.balance - money, expends: bank.expends + money)
      # bank.expends += money
      # bank.balance -= money
    else # 添加收入时，需要增、减余额
      # bank.incomes += money
      # bank.balance += money
      bank.update!(balance: bank.balance + money, incomes: bank.incomes + money)
    end
    bank.save!
  end

end
