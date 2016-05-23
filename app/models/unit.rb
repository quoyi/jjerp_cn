class Unit < ActiveRecord::Base
  belongs_to :unit_category
  belongs_to :supply
  belongs_to :order
  before_save :generate_code

  validates_presence_of :order_id, :full_name, :length, :width, :uom

  def generate_code
    # self.name = 
  end
end
