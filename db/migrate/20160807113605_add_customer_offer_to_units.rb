class AddCustomerOfferToUnits < ActiveRecord::Migration
  def change
    add_column :units, :is_custom, :boolean, default: false
  end
end
