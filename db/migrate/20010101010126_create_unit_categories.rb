class CreateUnitCategories < ActiveRecord::Migration
  def change
    # 部件类型
    create_table :unit_categories do |t|
      t.string :name, null: false, uniq: true # 名称
      t.string :note # 备注
      t.boolean :deleted, null: false, default: false
      t.timestamps null: false
    end
  end
end
