class Unit < ActiveRecord::Base
  belongs_to :unit_category
  belongs_to :supply
  belongs_to :order
  validates_format_of :number, with: /\A[0-9]+.[0-9]+\Z/
  # validates_format_of :size, with: /\A[1-9][0-9]+[Xx*×][1-9][0-9]+\Z/  # 验证成型尺寸是否符合规则 number Xx*× number
  validates_presence_of :order_id, :number, :length, :width, :uom

  def ply_name
    MaterialCategory.find_by(id: self.ply).try(:name)
  end

  def color_name
    MaterialCategory.find_by(id: self.color).try(:name)
  end

  def texture_name
    MaterialCategory.find_by(id: self.texture).try(:name) 
  end
end
