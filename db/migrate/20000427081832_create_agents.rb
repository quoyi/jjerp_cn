class CreateAgents < ActiveRecord::Migration
  def change
    # 代理商
    create_table :agents do |t|
      t.string :name, null: false, index: true, default: '' # 代理商编号
      t.string :province # 省
      t.string :city # 市
      t.string :district # 县
      t.string :town # 镇
      t.string :address # 地址
      t.string :full_name, null: false, index: true # 代理商名称,需要查询
      t.string :contacts # 负责人姓名
      t.string :mobile # 手机
      t.string :e_account # 电子账号QQ
      t.string :fax # 传真
      t.string :email # 邮箱
      t.string :wechar # 微信
      t.decimal :balance, precision: 8, scale: 2, null: false, default: 0 # 余额
      t.decimal :arrear, precision: 8, scale: 2, null: false, default: 0 # 欠款
      t.decimal :history, precision: 8, scale: 2, null: false, default: 0 # 历史订单总金额
      t.string :logistics # 指定物流
      t.integer :order_condition # 下单条件
      t.integer :send_condition # 发货条件
      t.string :cycle # 结账周期（天）
      t.string :note # 备注
      t.boolean :deleted, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
