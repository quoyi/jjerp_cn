class CreateExpends < ActiveRecord::Migration[6.0]
  def change
    # 支出
    create_table :expends do |t|
      t.string :name
      t.references :bank
      t.string :reason # 支出事由
      t.decimal :money, precision: 8, scale: 2 # 支出金额
      t.string :username # 经手人
      t.datetime :expend_at # 支出时间
      t.integer :status # 状态
      t.string :note # 备注
      t.boolean :deleted, null: false, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
