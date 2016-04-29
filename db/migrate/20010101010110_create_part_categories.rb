class CreatePartCategories < ActiveRecord::Migration
  def change
    # 配件类型
    create_table :part_categories do |t|
      t.string :name # 名称
      t.string :note # 备注
      t.timestamps null: false
    end
  end
end
