class CreateIndents < ActiveRecord::Migration
  def change
    # 总订单
    create_table :indents do |t|
      t.string :name, null: false, index: true, uniq: true # 编码
      t.references :agent, null: false, index: true # 代理商
      t.integer :status, null: false, default: 0 # 状态
      t.string :customer # 终端客户
      t.integer :ply, null: false, default: 0 # 厚度
      t.integer :texture, null: false, default: 0 # 材质
      t.integer :face, null: false, default: 0 # 表面
      t.integer :color, null: false, default: 0 # 颜色
      t.integer :oftype, null: false, default: 1 # 订单类型: 1.正常单  2.补单  3.加急单 4.批量单
      t.string :origin # 补单源单号
      t.datetime :offer_at # 报价时间
      t.datetime :check_at # 财务确认时间
      t.datetime :verify_at # 回传确认时间
      t.datetime :require_at # 要求发货时间
      t.datetime :send_at # 发货时间
      t.string :history # 记录状态历史
      t.string :note # 备注
      t.boolean :deleted, null: false, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
