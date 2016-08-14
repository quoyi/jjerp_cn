class CreateSents < ActiveRecord::Migration
  def change
    # 发货
    create_table :sents do |t|
      t.integer :owner_id, null: false #indent_id 或者order_id 根据owner_type决定
      t.string :owner_type, null: false
      t.integer :sent_list_id
      t.string :name
      t.datetime :sent_at
      t.string :area
      t.string :receiver, null: false
      t.string :contact, null: false #联系方式
      t.integer :cupboard, default: 0 
      t.integer :robe, default: 0 
      t.integer :door, default: 0 
      t.integer :part, default: 0 
      t.decimal :collection, precision: 8, scale: 2, default: 0 #代收
      t.string :logistics, null: false
      t.string :logistics_code, null: false

      t.timestamps null: false
    end
  end
end
