class CreateSents < ActiveRecord::Migration
  def change
    # 发货
    create_table :sents do |t|
      t.references :indent, index: true, foreign_key: true
      t.string :name
      t.datetime :sent_at
      t.string :area
      t.string :receiver, null: false
      t.string :contact, null: false
      t.integer :cupboard, default: 0 
      t.integer :robe, default: 0 
      t.integer :door, default: 0 
      t.integer :part, default: 0 
      t.decimal :collection, precision: 8, scale: 2, default: 0 
      t.string :logistics, null: false
      t.string :logistics_code, null: false

      t.timestamps null: false
    end
  end
end
