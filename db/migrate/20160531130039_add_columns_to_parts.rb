class AddColumnsToParts < ActiveRecord::Migration
  def change
    add_column :parts, :is_printed, :boolean, default: false
  end
end
