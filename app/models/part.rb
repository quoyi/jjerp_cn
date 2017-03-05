# == Schema Information
#
# Table name: parts
#
#  id               :integer          not null, primary key
#  part_category_id :integer          not null
#  order_id         :integer          not null
#  name             :string(255)
#  buy              :decimal(8, 2)
#  price            :decimal(8, 2)
#  store            :integer          default(1), not null
#  uom              :string(255)
#  number           :decimal(8, 4)    default(1.0), not null
#  brand            :string(255)
#  note             :string(255)
#  supply_id        :integer          not null
#  is_printed       :boolean          default(FALSE)
#  deleted          :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Part < ActiveRecord::Base
  belongs_to :part_category
  belongs_to :supply
  belongs_to :order
  validates_presence_of :part_category_id, :price, :supply_id

  before_create :generate_name

  # 自动生成编号
  def generate_name
    self.name = self.order.name + "-p-" + (Part.where(order_id: self.order.id).size + 1).to_s
  end

end
