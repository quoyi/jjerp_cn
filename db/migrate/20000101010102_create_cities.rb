class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.references :province, index: true, foreign_key: true
      t.string :name
    end
    add_index :cities, [:province_id, :name], unique: true
  end
end
