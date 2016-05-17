class CreateIndents < ActiveRecord::Migration
  def change
    # 总订单
    create_table :indents do |t|
      t.string :name, null: false, index: true, uniq: true # 编码
      t.references :agent, null: false, index: true # 代理商
      t.string :customer # 终端客户
      t.datetime :verify_at # 回传确认时间
      t.datetime :require_at # 要求发货时间
      t.string :note # 备注
      t.boolean :deleted, null: false, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
