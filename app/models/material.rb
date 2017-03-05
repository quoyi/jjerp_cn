# == Schema Information
#
# Table name: materials
#
#  id         :integer          not null, primary key
#  name       :string(255)      default(""), not null
#  full_name  :string(255)      not null
#  ply        :integer          not null
#  texture    :integer          not null
#  color      :integer          not null
#  store      :integer          default(1), not null
#  buy        :decimal(8, 2)    not null
#  price      :decimal(8, 2)    not null
#  uom        :string(255)
#  supply_id  :integer
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Material < ActiveRecord::Base
  belongs_to :material_category
  belongs_to :supply
  has_many :unit
  before_create :generate_code
  validates_presence_of :ply, :texture, :color, :buy, :price
  # 联合唯一
  validates_uniqueness_of :ply, scope: [:texture, :color]
  
  # 生成编码
  def generate_code
    self.name = "JCBL" + Time.new.strftime('%y%m%d') + SecureRandom.hex(2).upcase
    _ply = MaterialCategory.find_by_id(self.ply).try(:name)
    _texture = MaterialCategory.find_by_id(self.texture).try(:name)
    _color = MaterialCategory.find_by_id(self.color).try(:name)
    self.full_name = _color + _texture + _ply
  end
end
