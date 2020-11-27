class UpdateOrdersAddPackagedAt < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :produced_at, :datetime # 生产时间
    add_column :orders, :packaged_at, :datetime # 打包时间
    add_column :orders, :sent_at, :datetime     # 发货时间
    add_column :orders, :over_at, :datetime     # 结束时间
  end
end
