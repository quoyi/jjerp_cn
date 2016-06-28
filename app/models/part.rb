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
