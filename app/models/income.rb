class Income < ActiveRecord::Base
  belongs_to :indent
  belongs_to :bank
  after_save :update_indent_money

  # 应收、已收
  attr_accessor :should, :yet

  # 添加收入记录后，需要修改订单的“已收”
  def update_indent_money
    self.indent.arrear += self.money
    self.indent.save!
  end
end
