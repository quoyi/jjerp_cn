class UpdatePartNumberScale < ActiveRecord::Migration[6.0]
  def change
  	change_column :parts, :number, :decimal, precision: 8, scale: 4, default: 1
  end
end
