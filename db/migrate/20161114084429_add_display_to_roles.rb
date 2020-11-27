class AddDisplayToRoles < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :display, :boolean, null: false, default: true
  end
end
