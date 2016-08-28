class AddBalanceToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :balance, :decimal, precision: 8, scale: 2
  end
end
