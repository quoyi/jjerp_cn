# == Schema Information
#
# Table name: orders
#
#  id                    :integer          not null, primary key
#  indent_id             :integer          not null
#  name                  :string(255)      default(""), not null
#  order_category_id     :integer          default(1), not null
#  customer              :string(255)
#  ply                   :integer          default(0), not null
#  texture               :integer          default(0), not null
#  color                 :integer          default(0), not null
#  length                :integer          default(1), not null
#  width                 :integer          default(1), not null
#  height                :integer          default(1), not null
#  number                :integer          default(1), not null
#  price                 :decimal(12, 2)   default(0.0)
#  arrear                :decimal(12, 2)   default(0.0)
#  material_price        :decimal(8, 2)    default(0.0)
#  status                :integer          default(0), not null
#  oftype                :integer          default(0), not null
#  package_num           :integer          default(0), not null
#  note                  :string(255)
#  delivery_address      :string(255)      default(""), not null
#  deleted               :boolean          default(FALSE), not null
#  is_use_order_material :boolean          default(FALSE)
#  agent_id              :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  index                 :integer
#  handler               :integer          default(0), not null
#  material_number       :decimal(8, 2)    default(0.0), not null
#  produced_at           :datetime
#  packaged_at           :datetime
#  sent_at               :datetime
#  over_at               :datetime
#

class OrderPart < Order
  # 设定表名为 orders
  self.table_name = 'orders'
end
