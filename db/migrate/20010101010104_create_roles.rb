class CreateRoles < ActiveRecord::Migration[6.0]
  def change
    # 角色
    create_table :roles do |t|
      t.string :name, null: false, index: true, uniq: true # 角色名称
      t.string :nick, null: true, uniq: true # 角色别名
      t.string :note # 备注
      t.boolean :deleted, null: false, default: false # 标记删除

      t.timestamps null: false
    end
  end
end
