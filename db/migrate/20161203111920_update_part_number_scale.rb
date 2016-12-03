class UpdatePartNumberScale < ActiveRecord::Migration
  def change
  	change_column :parts, :number, :decimal, precision: 8, scale: 4, default: 1
  end
end
