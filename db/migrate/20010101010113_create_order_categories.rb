class CreateOrderCategories < ActiveRecord::Migration
  def change
    # 子订单类型
    create_table :order_categories do |t|
      t.string :name # 名称
      t.string :code, null: false, index: true # 编码
      t.string :note # 备注
      t.boolean :deleted, null: false, default: false
      t.timestamps null: false
    end
  end
end
