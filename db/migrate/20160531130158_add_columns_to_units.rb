class AddColumnsToUnits < ActiveRecord::Migration
  def change
    add_column :units, :is_printed, :boolean, default: false
  end
end
