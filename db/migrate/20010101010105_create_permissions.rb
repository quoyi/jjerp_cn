class CreatePermissions < ActiveRecord::Migration
  def change
    # 权限
    create_table :permissions do |t|
      t.string :name # 权限名称
      t.string :klass, null: false # 权限类名
      t.string :actions, null: false # 权限 action 名称，CRUD
      t.string :note # 备注
      t.boolean :deleted, null: false, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
