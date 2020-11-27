class CreateRolePermissions < ActiveRecord::Migration[6.0]
  def change
    # 角色 -- 权限 中间表
    create_table :role_permissions do |t|
      t.references :role, index: true
      t.references :permission, index: true
      t.string :klass, null: false # 权限类名
      t.string :actions, null: false # 权限 action 名称，CRUD
      t.string :note # 备注
      t.timestamps null: false
    end
  end
end
