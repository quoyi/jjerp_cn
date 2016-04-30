class OrderCategory < ActiveRecord::Base
  has_many :order
  validates :name, presence: true, uniqueness: true
end
