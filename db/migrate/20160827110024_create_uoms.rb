class CreateUoms < ActiveRecord::Migration
  def change
    create_table :uoms do |t|
      t.string :name, null: false, default: ""
      t.string :val
      t.string :note
      t.boolean :deleted

      t.timestamps null: false
    end

    add_index :uoms, :name, unique: true
  end
end
