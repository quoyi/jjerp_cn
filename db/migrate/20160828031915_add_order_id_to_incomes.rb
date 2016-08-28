class AddOrderIdToIncomes < ActiveRecord::Migration
  def change
    add_reference :incomes, :order, index: true, foreign_key: true
    add_column :incomes, :source, :string
  end
end
