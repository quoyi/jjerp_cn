class Income < ActiveRecord::Base
  belongs_to :indent
  belongs_to :bank
  belongs_to :order
  before_create :set_indent_id
  # after_save :update_other_orders_money

  # 应收、已收
  attr_accessor :should, :yet

  def set_indent_id
    self.indent_id = self.order.indent.id
  end

  # 添加收入记录后，需要修改订单的“已收”、"欠款"
  # def update_other_orders_money
  #   # self.indent.arrear -= self.money
  #   # self.indent.total_arrear -= self.money
  #   # self.indent.save!
  # end
end
