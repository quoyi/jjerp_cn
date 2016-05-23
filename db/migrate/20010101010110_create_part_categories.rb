class CreatePartCategories < ActiveRecord::Migration
  def change
    # 配件类型
    create_table :part_categories do |t|
      t.references :parent, default: 1 # 自连接
      # t.boolean :is_basic, null: false, default: false # 是否为基本类型
      t.string :name, null: false, default: '' # 名称
      t.string :note # 备注
      t.boolean :deleted, default: false # 标记删除
      t.timestamps null: false
    end

    add_index :part_categories, :name, unique: true
  end
end
