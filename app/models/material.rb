class Material < ActiveRecord::Base
  belongs_to :material_category
  belongs_to :supply
  has_many :unit
  validates_presence_of :name, :ply, :texture, :color, :buy, :price, :supply_id
  before_create :generate_code

  # 生成编码
  def generate_code
    self.name = "JCBL" + Time.new.strftime('%y%m%d') + SecureRandom.hex(1).upcase
  end
end
