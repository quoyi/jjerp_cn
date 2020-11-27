class CreateDistricts < ActiveRecord::Migration[6.0]
  def change
    # 区、县
    create_table :districts do |t|
      t.references :city, index: true, foreign_key: true
      t.string :name
    end
    add_index :districts, [:city_id, :name], unique: true
  end
end
