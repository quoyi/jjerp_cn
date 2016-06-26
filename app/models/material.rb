class Material < ActiveRecord::Base
  belongs_to :material_category
  belongs_to :supply
  has_many :unit
  before_create :generate_code
  validates_presence_of :ply, :texture, :color, :buy, :price, :supply_id
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
