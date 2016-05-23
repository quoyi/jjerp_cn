class Part < ActiveRecord::Base
  belongs_to :part_category
  belongs_to :supply
  belongs_to :order
  validates_presence_of :part_category_id, :name, :buy, :price, :supply_id
end
