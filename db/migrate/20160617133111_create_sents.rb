class CreateSents < ActiveRecord::Migration[6.0]
  def change
    # 发货
    create_table :sents do |t|
      t.integer :owner_id, null: false
      t.string :owner_type, null: false
      t.integer :sent_list_id
      t.string :name
      t.datetime :sent_at
      t.string :area
      t.string :receiver, null: false # 收货人
      t.string :contact, null: false #联系方式
      t.integer :cupboard, default: 0 
      t.integer :robe, default: 0 
      t.integer :door, default: 0 
      t.integer :part, default: 0 
      t.decimal :collection, precision: 8, scale: 2, default: 0 #代收
      t.string :logistics, null: false, default: "" # 物流
      t.string :logistics_code, null: false, default: "" # 物流号

      t.timestamps null: false
    end
  end
end
