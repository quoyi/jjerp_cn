class IncomesAndExpendsForBanks < ActiveRecord::Migration
  def change
    add_column :banks, :incomes, :decimal, precision: 8, scale: 2, default:0 # 收入合计
    add_column :banks, :expends, :decimal, precision: 8, scale: 2, default:0 # 支出合计
  end
end
