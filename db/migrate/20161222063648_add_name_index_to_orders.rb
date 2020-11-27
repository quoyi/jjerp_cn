class AddNameIndexToOrders < ActiveRecord::Migration[6.0]
  def change
  end
  add_index :orders, :name, unique: true
end
