class CreateOrders < ActiveRecord::Migration
  def change
    # 子订单
    create_table :orders do |t|
      t.references :indent, null: false, index: true # 总定单号
      t.string :name, null: false, default: '' # 编码
      t.references :order_category, null: false, default: 1 # 订单类型: 1. 橱柜  2.地柜  3.家具等
      t.integer :ply, null: false, default: 0 # 厚度
      t.integer :texture, null: false, default: 0 # 材质
      t.integer :color, null: false, default: 0 # 颜色
      t.integer :length, null: false, default: 1
      t.integer :width, null: false, default: 1
      t.integer :height, null: false, default: 1
      t.integer :number, null: false, default: 1 # 数量
      t.decimal :price, precision: 8, scale: 2, default: 0 # 价格
      t.integer :status, null: false, default: 0 # 状态: 0.正常 1.异常
      t.string :note # 备注
      t.boolean :deleted, null: false, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
