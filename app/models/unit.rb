class Unit < ActiveRecord::Base
  belongs_to :unit_category
  belongs_to :supply
  belongs_to :order
end
