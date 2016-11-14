class AddDisplayToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :display, :boolean, null: false, default: true
  end
end
