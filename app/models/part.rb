class Part < ApplicationRecord
  belongs_to :part_category
  belongs_to :supply
  belongs_to :order
  validates_presence_of :part_category_id, :price, :supply_id

  before_create :generate_name

  # 自动生成编号
  def generate_name
    self.name = "#{order.name}-p-#{Part.where(order_id: order.id).size + 1}"
  end
end

# == Schema Information
#
# Table name: parts
#
#  id               :integer          not null, primary key
#  brand            :string(255)
#  buy              :decimal(8, 2)
#  deleted          :boolean          default(FALSE)
#  is_printed       :boolean          default(FALSE)
#  name             :string(255)
#  note             :string(255)
#  number           :decimal(8, 4)    default(1.0), not null
#  price            :decimal(8, 2)
#  store            :integer          default(1), not null
#  uom              :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  order_id         :integer          not null
#  part_category_id :integer          not null
#  supply_id        :integer          not null
#
# Indexes
#
#  index_parts_on_name              (name)
#  index_parts_on_part_category_id  (part_category_id)
#  index_parts_on_supply_id         (supply_id)
#
