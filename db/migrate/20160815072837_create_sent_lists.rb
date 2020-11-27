class CreateSentLists < ActiveRecord::Migration[6.0]
  # 发货清单
  def change
    create_table :sent_lists do |t|
      t.string :name #编号
      t.integer :total #数量合计
      t.string :created_by #负责人 
      t.boolean :deleted #状态

      t.timestamps null: false
    end
  end
end
