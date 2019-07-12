class OrderPart < Order
  # 设定表名为 orders
  self.table_name = 'orders'
end

# == Schema Information
#
# Table name: orders
#
#  id                    :integer          not null, primary key
#  arrear                :decimal(12, 2)   default(0.0)
#  color                 :integer          default(0), not null
#  customer              :string(255)
#  deleted               :boolean          default(FALSE), not null
#  delivery_address      :string(255)      default(""), not null
#  handler               :integer          default(0), not null
#  height                :integer          default(1), not null
#  index                 :integer
#  is_use_order_material :boolean          default(FALSE)
#  length                :integer          default(1), not null
#  material_number       :decimal(8, 2)    default(0.0), not null
#  material_price        :decimal(8, 2)    default(0.0)
#  name                  :string(255)      default(""), not null
#  note                  :string(255)
#  number                :integer          default(1), not null
#  oftype                :integer          default(0), not null
#  over_at               :datetime
#  package_num           :integer          default(0), not null
#  packaged_at           :datetime
#  ply                   :integer          default(0), not null
#  price                 :decimal(12, 2)   default(0.0)
#  produced_at           :datetime
#  sent_at               :datetime
#  status                :integer          default(0), not null
#  texture               :integer          default(0), not null
#  width                 :integer          default(1), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  agent_id              :integer
#  indent_id             :integer          not null
#  order_category_id     :integer          default(1), not null
#
# Indexes
#
#  index_orders_on_agent_id   (agent_id)
#  index_orders_on_indent_id  (indent_id)
#  index_orders_on_name       (name) UNIQUE
#
