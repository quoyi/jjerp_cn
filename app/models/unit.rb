class Unit < ActiveRecord::Base
  belongs_to :unit_category
  belongs_to :supply
  belongs_to :order

  validates_presence_of :order_id, :full_name, :length, :width, :uom

  # def generate_unit_code
  #   # self.name = 
  # end

  def ply_name
    MaterialCategory.find_by(id: self.ply).try(:name)
  end

  def color_name
    MaterialCategory.find_by(id: self.color).try(:name)
  end

end
