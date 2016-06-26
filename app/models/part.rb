class Part < ActiveRecord::Base
  include OrdersHelper
  belongs_to :part_category
  belongs_to :supply
  belongs_to :order
  validates_presence_of :part_category_id, :price, :supply_id

  # before_save :generate_name
  after_save :update_order_or_indent

  # def generate_name
  #   # 没有填写名称时，复制配件类型名称
  #   self.name = self.part_category.try(:name) if self.name.blank?
  # end

  # 修改子订单和总订单
  def update_order_or_indent
    # 调用 OrdersHelper 中的 update_order_and_indent 方法
    update_order_and_indent(self.order)
  end
end
