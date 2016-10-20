class AddSerialToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :serial, :string, null: false, default: ''
  end
end
