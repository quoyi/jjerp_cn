class CreateOrders < ActiveRecord::Migration
  def change
    # 子订单
    create_table :orders do |t|
      t.references :indent, null: false, index: true # 总定单号
      t.string :name, null: false # 编码
      t.references :order_category, null: false # 订单类型: 1. 橱柜  2.地柜  3.家具等
      t.string :customer # 终端客户
      t.integer :ply, null: false, default: 0 # 厚度
      t.integer :texture, null: false, default: 0 # 材质
      t.integer :face, null: false, default: 0 # 表面
      t.integer :color, null: false, default: 0 # 颜色
      t.integer :length, null: false, default: 0
      t.integer :width, null: false, default: 0
      t.integer :height, null: false, default: 0
      t.integer :number, null: false, default: 0 # 数量
      t.integer :oftype, null: false, default: 1 # 订单类型: 1.正常单  2.补单  3.加急单 4.批量单
      t.string :origin # 补单源单号
      t.datetime :offer_at # 报价时间
      t.datetime :check_at # 财务确认时间
      t.datetime :verify_at # 回传确认时间
      t.datetime :require_at # 要求发货时间
      t.datetime :send_at # 发货时间
      t.integer :status, null: false, default: 0 # 状态: 0.正常 1.异常
      t.string :history # 历史状态
      t.string :note # 备注
      t.boolean :deleted, null: false, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
