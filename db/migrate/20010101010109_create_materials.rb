class CreateMaterials < ActiveRecord::Migration
  def change
    # 板料
    create_table :materials do |t|
      t.string :serial # 编码
      t.string :name # 名称
      t.integer :ply, null: false # 厚度（板料种类主键）
      t.integer :texture, null: false # 材质（板料种类主键）
      t.integer :face, null: false # 表面（板料种类主键）
      t.integer :color, null: false # 颜色（板料种类主键）
      t.integer :store, null: false, default: 1 # 库存
      t.decimal :buy, precision: 8, scale: 2 # 进货单价（仅管理员和财务可见）
      t.decimal :sell, precision: 8, scale: 2 # 出售单价
      t.string :unit # 单位
      t.references :supply, index: true, foreign_key: true # 供应商
      t.timestamps null: false
    end
  end
end
