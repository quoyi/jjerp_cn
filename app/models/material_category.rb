class MaterialCategory < ActiveRecord::Base
  has_many :material
  validates_presence_of :oftype, :name

  #下单条件：1.厚度 2.材质 3.颜色
  enum oftype: [:ply, :texture, :color]

  def self.oftype
    [['厚度', 'ply'], ['材质', 'texture'], ['颜色', 'color']]
  end

  def oftype_name
    case oftype
      when 'ply' then '厚度'
      when 'texture' then '材质'
      when 'color' then '颜色'
    else
      "未知状态"
    end
  end
end
