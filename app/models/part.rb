class Part < ActiveRecord::Base
  belongs_to :part_category
  belongs_to :supply
  validates_presence_of :part_category_id, :name, :buy, :sell, :supply_id
end
