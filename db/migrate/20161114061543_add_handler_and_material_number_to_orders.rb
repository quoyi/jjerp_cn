class AddHandlerAndMaterialNumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :handler, :integer, null: false, default: 0
    add_column :orders, :material_number, :decimal, precision: 8, scale: 2, null: false, default: 0
  end
end
