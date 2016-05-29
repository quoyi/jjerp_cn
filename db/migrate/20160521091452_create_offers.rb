class CreateOffers < ActiveRecord::Migration
  def change
    # 报价单
    create_table :offers do |t|
      t.references :indent, index: true
      t.references :order, index: true # 订单号
      t.integer :display # 显示序号
      t.integer :item # 项目
      #t.string :item_name # 项目名称
      t.string :uom # 单位
      t.decimal :number # 数量
      t.decimal :price, precision: 8, scale: 2 # 单价（默认为材料价格）
      t.decimal :sum, precision: 8, scale: 2 # 项目合计
      t.decimal :total, precision: 8, scale: 2 # 订单合计
      t.string :note # 备注
      t.boolean :deleted, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
