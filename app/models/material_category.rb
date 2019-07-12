class MaterialCategory < ActiveRecord::Base
  has_many :material
  validates_presence_of :oftype, :name
  # validates :name, uniqueness: {scope: :oftype}
  validates_uniqueness_of :name, scope: :oftype

  # 下单条件：1.厚度 2.材质 3.颜色
  enum oftype: %i[ply texture color]

  def self.oftype
    [%w[厚度 ply], %w[材质 texture], %w[颜色 color]]
  end

  def oftype_name
    case oftype
    when 'ply' then '厚度'
    when 'texture' then '材质'
    when 'color' then '颜色'
    else
      '未知状态'
    end
  end
end

# == Schema Information
#
# Table name: material_categories
#
#  id         :integer          not null, primary key
#  deleted    :boolean          default(FALSE)
#  name       :string(255)
#  note       :string(255)
#  oftype     :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_material_categories_on_oftype  (oftype)
#
