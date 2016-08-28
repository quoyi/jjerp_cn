class CreateUoms < ActiveRecord::Migration
  def change
    create_table :uoms do |t|
      t.string :name, null: false, default: ""
      t.string :val
      t.string :note, default: ""
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :uoms, :name, unique: true
  end
end
