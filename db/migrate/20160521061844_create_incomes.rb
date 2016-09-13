class CreateIncomes < ActiveRecord::Migration
  def change
    # 收入
    create_table :incomes do |t|
      t.string :name
      t.references :bank, index: true # 银行卡
      t.string :reason # 收入来源
      t.references :indent, index: true, null: false # 所属总订单
      t.decimal :money, precision: 8, scale: 2 # 收入金额
      t.string :username # 经手人
      t.datetime :income_at, index: true # 收入时间
      t.integer :status # 状态
      t.string :note # 备注
      t.boolean :deleted, null: false, default: false # 标记删除
      t.references :order, index: true, null: false # 所属子订单
      t.string :source, default: ""
      t.timestamps null: false
    end
  end
end
