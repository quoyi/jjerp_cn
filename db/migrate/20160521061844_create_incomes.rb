class CreateIncomes < ActiveRecord::Migration
  def change
    # 收入
    create_table :incomes do |t|
      t.string :name
      t.string :reason # 收入来源
      t.references :indent, index: true # 订单号
      t.decimal :money, precision: 8, scale: 2 # 收入金额
      t.string :username # 经手人
      t.datetime :income_at # 收入时间
      t.integer :status # 状态
      t.string :note # 备注
      t.boolean :deleted, null: false, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
