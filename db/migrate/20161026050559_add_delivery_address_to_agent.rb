class AddDeliveryAddressToAgent < ActiveRecord::Migration
  def change
    add_column :agents, :delivery_address, :string, null: false, default: ''
  end
end
