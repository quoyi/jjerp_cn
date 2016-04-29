class CreateMaterialCategories < ActiveRecord::Migration
  def change
    # 板料类型
    create_table :material_categories do |t|
      t.integer :oftype, null: false # 类型: 0. 厚度  1. 材质  2.表面  3.颜色
      t.string :name # 名称
      t.string :note # 备注
      t.timestamps null: false
    end
  end
end
