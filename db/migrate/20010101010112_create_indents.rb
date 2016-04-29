class CreateIndents < ActiveRecord::Migration
  def change
    # 总订单
    create_table :indents do |t|
      t.string :name, null: false, index: true, uniq: true # 编码
      t.references :user, null: false, index: true # 代理商
      t.integer :status, null: false, default: 0 # 状态
      t.string :history # 记录状态历史
      t.boolean :deleted, null: false, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
