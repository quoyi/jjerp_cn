class CreateMaterials < ActiveRecord::Migration[6.0]
  def change
    # 板料
    create_table :materials do |t|
      t.string :name, null: false, default: '' # 编码
      t.string :full_name, null: false # 名称
      t.integer :ply, null: false # 厚度（板料种类主键）
      t.integer :texture, null: false # 材质（板料种类主键）
      t.integer :color, null: false # 颜色（板料种类主键）
      t.integer :store, null: false, default: 1 # 库存
      t.decimal :buy, null: false, precision: 8, scale: 2 # 进货单价（仅管理员和财务可见）
      t.decimal :price, null: false, precision: 8, scale: 2 # 出售单价
      t.string :uom # 单位
      t.references :supply, index: true, foreign_key: true # 供应商
      t.boolean :deleted, default: false # 标记删除
      t.timestamps null: false
    end

    add_index :materials, [:ply, :texture, :color], :unique => true
  end
end
