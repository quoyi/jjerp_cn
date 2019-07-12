class Material < ActiveRecord::Base
  belongs_to :material_category
  belongs_to :supply
  has_many :unit
  before_create :generate_code
  validates_presence_of :ply, :texture, :color, :buy, :price
  # 联合唯一
  validates_uniqueness_of :ply, scope: %i[texture color]

  # 生成编码
  def generate_code
    self.name = 'JCBL' + Time.new.strftime('%y%m%d') + SecureRandom.hex(2).upcase
    ply = MaterialCategory.find_by_id(ply).try(:name)
    texture = MaterialCategory.find_by_id(texture).try(:name)
    color = MaterialCategory.find_by_id(color).try(:name)
    self.full_name = color + texture + ply
  end
end

# == Schema Information
#
# Table name: materials
#
#  id         :integer          not null, primary key
#  buy        :decimal(8, 2)    not null
#  color      :integer          not null
#  deleted    :boolean          default(FALSE)
#  full_name  :string(255)      not null
#  name       :string(255)      default(""), not null
#  ply        :integer          not null
#  price      :decimal(8, 2)    not null
#  store      :integer          default(1), not null
#  texture    :integer          not null
#  uom        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  supply_id  :integer
#
# Indexes
#
#  index_materials_on_ply_and_texture_and_color  (ply,texture,color) UNIQUE
#  index_materials_on_supply_id                  (supply_id)
#
# Foreign Keys
#
#  fk_rails_...  (supply_id => supplies.id)
#
