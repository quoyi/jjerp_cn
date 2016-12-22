class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name, null: false, index: true # 模板名称
      t.integer :creator, null: false # 创建者
      t.decimal :price, precision: 8, scale: 2, default: 0 # 单价
      t.integer :times, default: 0 # 使用次数
      
      t.timestamps null: false
    end
  end
end
