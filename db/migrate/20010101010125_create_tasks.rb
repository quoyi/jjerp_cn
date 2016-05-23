class CreateTasks < ActiveRecord::Migration
  def change
    # 生产任务
    create_table :tasks do |t|
      t.references :order, index: true, foreign_key: true #订单号
      t.integer :item_id, index: true # 物料／配件id，用polymorphic方式
      t.string :item_type # 物料／配件
      t.string :sequence # 所需工序
      t.decimal :area, precision: 9, scale: 6  # 本单大板的面积
      t.integer :mix_status, default: 0   #混单状态：未混单，已混单，不需要混单
      t.decimal :availability, precision: 8, scale: 2  #不混单下 材料的利用率
      t.integer :work, default: 0  #工序进度
      t.integer :state #板料或者配件
      t.integer :number #所需物料或者配件的数量
      t.boolean :deleted, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
