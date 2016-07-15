class Bank < ActiveRecord::Base
  has_many :income
  has_many :expend

  validates_presence_of :name, :bank_name, :bank_card
  validates_uniqueness_of :name, message: '编号或简称重复！'
  validates_uniqueness_of :bank_card, scope: [:name, :bank_name], message: '账户信息重复！'
end
