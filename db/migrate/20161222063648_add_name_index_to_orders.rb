class AddNameIndexToOrders < ActiveRecord::Migration
  def change
  end
  add_index :orders, :name, unique: true
end
