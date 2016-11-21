class RemoveMaterialNumberFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :material_number, :decimal, precision: 8, scale: 2, null: false, default: 0
  end
end
