class AddIsUseOrderMaterialToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :is_use_order_material, :boolean, default: false # 使用子订单的板料属性或使用部件板料属性 标记
  end
end
