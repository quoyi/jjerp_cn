class Bank < ApplicationRecord
  has_many :income
  has_many :expend
  before_save :set_default_bank

  validates_presence_of :name, :bank_name, :bank_card
  # validates_uniqueness_of :name, message: '编号或简称重复！'
  validates_uniqueness_of :bank_card, scope: [:bank_name], message: '账户信息重复！'

  def set_default_bank
    self.is_default = 1 if Bank.count.zero?
  end
end

# == Schema Information
#
# Table name: banks
#
#  id         :integer          not null, primary key
#  balance    :decimal(12, 2)   default(0.0)
#  bank_card  :string(255)
#  bank_name  :string(255)
#  expends    :decimal(12, 2)   default(0.0)
#  incomes    :decimal(12, 2)   default(0.0)
#  is_default :boolean          default(FALSE)
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_banks_on_is_default  (is_default)
#
