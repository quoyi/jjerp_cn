class UnitCategory < ActiveRecord::Base
  has_many :unit
  validates :name, uniqueness: true
end
