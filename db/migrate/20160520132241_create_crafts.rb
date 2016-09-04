class CreateCrafts < ActiveRecord::Migration
  def change
    # 工艺
    create_table :crafts do |t|
      t.references :order # 所属订单号
      t.references :craft_category # 所属工艺
      t.string :full_name, index: true, default: '' # 名称
      t.string :uom # 单位
      t.decimal :price, precision: 8, scale: 2, null: false, default: 0 # 单价
      t.integer :number, null: false, default: 1 # 数量
      t.string :note # 备注
      t.boolean :status # 状态
      t.boolean :deleted, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
