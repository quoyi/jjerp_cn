class Bank < ActiveRecord::Base
  has_many :income
  has_many :expend
end
