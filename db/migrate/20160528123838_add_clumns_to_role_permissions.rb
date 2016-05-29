class AddClumnsToRolePermissions < ActiveRecord::Migration
  def change
    add_column :role_permissions, :klass, :string, null: false
    add_column :role_permissions, :actions, :string, null: false
  end
end
