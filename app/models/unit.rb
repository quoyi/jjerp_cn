class Unit < ActiveRecord::Base
  belongs_to :unit_category
  belongs_to :supply
  belongs_to :order
  validates_format_of :number, with: /\A[0-9]+.[0-9]+\Z/
  # validates_format_of :size, with: /\A[1-9][0-9]+[Xx*×][1-9][0-9]+\Z/  # 验证成型尺寸是否符合规则 number Xx*× number
  validates_presence_of :order_id, :number, :length, :width, :uom
  before_save :generate_name

  def ply_name
    MaterialCategory.find_by(id: self.ply).try(:name)
  end

  def color_name
    MaterialCategory.find_by(id: self.color).try(:name)
  end

  def texture_name
    MaterialCategory.find_by(id: self.texture).try(:name) 
  end

  def generate_name
    last = 0
    order_name = self.order.name
    unit_last = self.order.units.last
    last = unit_last.name.split("-B-".upcase())[1] if unit_last.present?

    self.name = (order_name + "-B-" + (last.to_i + 1).to_s).upcase() unless self.name.present?
  end
end
