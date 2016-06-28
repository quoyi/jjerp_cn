class Unit < ActiveRecord::Base
  belongs_to :unit_category
  belongs_to :supply
  belongs_to :order
  validates_format_of :size, with: /\A[1-9][0-9]+[Xx*×][1-9][0-9]+\Z/
  validates_presence_of :order_id, :full_name, :length, :width, :uom

  def ply_name
    MaterialCategory.find_by(id: self.ply).try(:name)
  end

  def color_name
    MaterialCategory.find_by(id: self.color).try(:name)
  end

end
