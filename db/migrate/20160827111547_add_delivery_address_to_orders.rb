class AddDeliveryAddressToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_address, :string
  end
end
