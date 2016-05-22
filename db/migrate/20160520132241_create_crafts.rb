class CreateCrafts < ActiveRecord::Migration
  def change
    # 工艺
    create_table :crafts do |t|
      t.string :name, index: true, null: false, uniq: true # 编码
      t.string :full_name # 名称
      t.string :note # 备注
      t.boolean :status # 状态
      t.boolean :deleted, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
