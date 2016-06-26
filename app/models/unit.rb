class Unit < ActiveRecord::Base
  include OrdersHelper
  belongs_to :unit_category
  belongs_to :supply
  belongs_to :order
  after_save :update_order_or_indent

  validates_presence_of :order_id, :full_name, :length, :width, :uom

  # def generate_unit_code
  #   # self.name = 
  # end

  # 修改子订单和总订单
  def update_order_or_indent
    # 调用 OrdersHelper 中的 update_order_and_indent 方法
    update_order_and_indent(self.order)
  end

  def ply_name
    MaterialCategory.find_by(id: self.ply).try(:name)
  end

  def color_name
    MaterialCategory.find_by(id: self.color).try(:name)
  end

end
