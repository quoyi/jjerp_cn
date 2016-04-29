class CreateRolePermissions < ActiveRecord::Migration
  def change
    # 角色 -- 权限 中间表
    create_table :role_permissions do |t|
      t.references :role, index: true
      t.references :permission, index: true
      t.timestamps null: false
    end
  end
end
