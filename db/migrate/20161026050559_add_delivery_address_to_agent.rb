class AddDeliveryAddressToAgent < ActiveRecord::Migration[6.0]
  def change
    add_column :agents, :delivery_address, :string, null: false, default: ''
  end
end
