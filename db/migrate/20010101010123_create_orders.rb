class CreateOrders < ActiveRecord::Migration
  def change
    # 子订单
    create_table :orders do |t|
      t.references :indent, null: false, index: true # 总定单号
      t.string :name, null: false, default: '' # 编码
      t.references :order_category, null: false, default: 1 # 订单类型: 1. 橱柜  2.地柜  3.家具等
      t.string :customer # 终端客户
      t.integer :ply, null: false, default: 0 # 厚度
      t.integer :texture, null: false, default: 0 # 材质
      t.integer :color, null: false, default: 0 # 颜色
      t.integer :length, null: false, default: 1
      t.integer :width, null: false, default: 1
      t.integer :height, null: false, default: 1
      t.integer :number, null: false, default: 1 # 数量
      t.decimal :price, precision: 8, scale: 2, default: 0 # 价格
      t.decimal :arrear, precision: 8, scale: 2, default: 0 # 欠款
      t.decimal :material_price, precision: 8, scale: 2, default: 0 # 板料价格
      t.integer :status, null: false, default: 0 # 状态: 0.报价中 1.已报价 2.生产中 3.已入库 4.已发货
      t.integer :oftype, null: false, default: 0 # 类型： 0.正常单 1.补单 3.加急单  4.批量单
      t.integer :package_num, null: false, default: 0 # 打包数
      t.string :note # 备注
      t.string :delivery_address, null: false, default: '' # 收货地址
      t.boolean :deleted, null: false, default: false # 标记删除
      t.boolean :is_use_order_material, default: false # 使用子订单的板料属性或使用部件板料属性 标记
      t.references :agent, index: true
      t.timestamps null: false
    end
  end
end
