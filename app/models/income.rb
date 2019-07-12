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

# == Schema Information
#
# Table name: incomes
#
#  id         :integer          not null, primary key
#  deleted    :boolean          default(FALSE), not null
#  income_at  :datetime
#  money      :decimal(12, 2)   default(0.0)
#  name       :string(255)
#  note       :string(255)
#  reason     :string(255)
#  source     :string(255)      default("")
#  status     :integer
#  username   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  agent_id   :integer
#  bank_id    :integer
#  indent_id  :integer
#  order_id   :integer
#
# Indexes
#
#  index_incomes_on_bank_id    (bank_id)
#  index_incomes_on_income_at  (income_at)
#
