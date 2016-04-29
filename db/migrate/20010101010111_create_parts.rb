class CreateParts < ActiveRecord::Migration
  def change
    # 配件
    create_table :parts do |t|
      t.references :part_category, null: false, index: true # 所属类型
      t.string :name, null: false, index: true # 名称
      t.decimal :buy, precision: 8, scale: 2 # 进价
      t.decimal :sell, precision: 8, scale: 2 # 售价
      t.integer :store, null: false, default: 0 # 库存
      t.string :brand # 品牌
      t.references :supply, null: false, index: true # 供货商
      t.timestamps null: false
    end
  end
end
