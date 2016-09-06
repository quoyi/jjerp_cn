class CreateCraftCategories < ActiveRecord::Migration
  def change
    # 工艺类型
    create_table :craft_categories do |t|
      t.string :full_name, null: false, default: '' # 工艺类型名称
      t.string :uom, default: '' # 单位
      t.decimal :price, precision: 8, scale: 2, null: false, default: 0 # 单价
      t.string :note # 备注
      t.boolean :deleted, default: 0

      t.timestamps null: false
    end

    add_index :craft_categories, :full_name, unique: true
  end
end
