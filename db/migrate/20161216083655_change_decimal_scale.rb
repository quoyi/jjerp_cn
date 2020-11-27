class ChangeDecimalScale < ActiveRecord::Migration[6.0]
  def change
  	change_column :agents, :balance, :decimal, precision: 12, scale: 2, null: false, default: 0
  	change_column :agents, :arrear, :decimal, precision: 12, scale: 2, null: false, default: 0
  	change_column :agents, :history, :decimal, precision: 12, scale: 2, null: false, default: 0

  	change_column :orders, :price, :decimal, precision: 12, scale: 2, default: 0
  	change_column :orders, :arrear, :decimal, precision: 12, scale: 2, default: 0

  	change_column :incomes, :money, :decimal, precision: 12, scale: 2, default: 0

  	change_column :expends, :money, :decimal, precision: 12, scale: 2, default: 0

  	change_column :offers, :sum, :decimal, precision: 12, scale: 2, default: 0
  	change_column :offers, :total, :decimal, precision: 12, scale: 2, default: 0

  	change_column :sents, :collection, :decimal, precision: 12, scale: 2, default: 0

  	change_column :banks, :balance, :decimal, precision: 12, scale: 2, default: 0
  	change_column :banks, :incomes, :decimal, precision: 12, scale: 2, default: 0
  	change_column :banks, :expends, :decimal, precision: 12, scale: 2, default: 0

  end
end
