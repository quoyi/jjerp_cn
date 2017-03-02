class Income < ActiveRecord::Base
  belongs_to :indent
  belongs_to :bank
  belongs_to :order
  belongs_to :agent
  scope :agent_earning, ->(agent_id) { where(agent_id: agent_id, order_id: nil).pluck(:money).sum.round(2) }
  scope :agent_orders_earning, ->(agent_id) { where('bank_id IS NULL AND order_id IS NOT NULL AND agent_id = ?', agent_id).pluck(:money).sum.round(2) }
  scope :indent_earning, ->(indent_id) { where(indent_id: indent_id).pluck(:money).sum.round(2) }
  scope :order_earning, ->(order_id) { where(order_id: order_id, bank_id: nil).pluck(:money).sum.round(2) }

  # after_save :update_other_orders_money

  # 应收、已收、收入类型
  attr_accessor :should, :yet

  # 添加收入记录后，需要修改订单的“已收”、"欠款"
  # def update_other_orders_money
  #   # self.indent.arrear -= self.money
  #   # self.indent.total_arrear -= self.money
  #   # self.indent.save!
  # end
end
