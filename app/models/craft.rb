class Craft < ActiveRecord::Base
  include OrdersHelper

  belongs_to :order

  after_save :update_order_or_indent

  # 修改子订单和总订单
  def update_order_or_indent
    # 调用 OrdersHelper 中的 update_order_and_indent 方法
    update_order_and_indent(self.order)
  end
end
