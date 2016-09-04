class CreateCraftCategories < ActiveRecord::Migration
  def change
    create_table :craft_categories do |t|
      t.string :full_name, null: false, default: ''
      t.string :uom, default: ''
      t.decimal :price, precision: 8, scale: 2, null: false, default: 0 # 单价
      t.string :note
      t.boolean :deleted, default: 0

      t.timestamps null: false
    end

    add_index :craft_categories, :full_name, unique: true
  end
end
