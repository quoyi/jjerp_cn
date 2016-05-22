class CreateUserCategories < ActiveRecord::Migration
  def change
    # 用户类型
    create_table :user_categories do |t|
      t.string :serial, null: false, index: true
      t.string :name, null: false, index: true, uniq: true # 名称
      t.string :nick, default: '' # 别名
      t.boolean :visible, null: false, default: true # 可见性
      t.boolean :deleted, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
