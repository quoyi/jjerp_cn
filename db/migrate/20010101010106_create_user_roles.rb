class CreateUserRoles < ActiveRecord::Migration[6.0]
  def change
    # 用户 -- 角色 中间表
    create_table :user_roles do |t|
      t.references :user, index: true
      t.references :role, index: true
      t.timestamps null: false
    end
  end
end
