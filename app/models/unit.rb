# == Schema Information
#
# Table name: units
#
#  id               :integer          not null, primary key
#  unit_category_id :integer          default(1)
#  order_id         :integer
#  name             :string(255)      default(""), not null
#  full_name        :string(255)
#  material_id      :integer
#  ply              :integer          default(1)
#  texture          :integer
#  color            :integer
#  length           :integer          default(1), not null
#  width            :integer          default(1), not null
#  number           :decimal(8, 2)    default(0.0), not null
#  uom              :string(255)
#  price            :decimal(8, 2)    default(0.0)
#  size             :string(255)      default("")
#  note             :string(255)
#  supply_id        :integer
#  is_custom        :boolean          default(FALSE)
#  is_printed       :boolean          default(FALSE)
#  edge             :string(255)
#  customer         :string(255)
#  out_edge_thick   :integer          default(0), not null
#  in_edge_thick    :integer          default(0), not null
#  back_texture     :string(255)
#  door_type        :string(255)
#  door_mould       :string(255)
#  door_handle_type :string(255)
#  door_edge_type   :string(255)
#  door_edge_thick  :integer
#  state            :integer          default(0)
#  craft            :string(255)
#  deleted          :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Unit < ActiveRecord::Base
  belongs_to :unit_category
  belongs_to :supply
  belongs_to :order
  validates_format_of :number, with: /\A[0-9]+.[0-9]+\Z/
  # validates_format_of :size, with: /\A[1-9][0-9]+[Xx*×][1-9][0-9]+\Z/  # 验证成型尺寸是否符合规则 number Xx*× number
  validates_presence_of :order_id, :number, :length, :width, :uom
  before_save :generate_name

  # scope :custom_size, lambda { |order_id|
  #   Unit.joins(:order).where('units.order_id = orders.id')
  # }

  def ply_name
    MaterialCategory.find_by(id: ply).try(:name)
  end

  def color_name
    MaterialCategory.find_by(id: color).try(:name)
  end

  def texture_name
    MaterialCategory.find_by(id: texture).try(:name)
  end

  def generate_name
    last = 0
    order_name = order.name
    unit_last = order.units.last
    last = unit_last.name.split('-B-'.upcase)[1] if unit_last.present?

    self.name = (order_name + '-B-' + (last.to_i + 1).to_s).upcase unless name.present?
  end

  # 指定 ply 是否为背板
  def backboard?
    # 这里不能指定 self.where() 的原因： 实例对象调用此方法时会报错。
    mc = MaterialCategory.find_by_id(ply)
    if mc
      # "3mm".to_i = 3 （取第一个数字类型转换为整数） ; 小于 10mm 的板料为背板
      mc.name.to_i < 10
    else
      false
    end
  end
end
