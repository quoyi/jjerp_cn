# == Schema Information
#
# Table name: offers
#
#  id         :integer          not null, primary key
#  indent_id  :integer
#  order_id   :integer
#  display    :integer
#  item_id    :integer
#  item_type  :integer          default(0)
#  item_name  :string(255)
#  uom        :string(255)
#  number     :decimal(10, 6)   default(0.0)
#  price      :decimal(8, 2)    default(0.0)
#  sum        :decimal(12, 2)   default(0.0)
#  total      :decimal(12, 2)   default(0.0)
#  note       :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Offer < ActiveRecord::Base
  include OrdersHelper
  belongs_to :indent
  belongs_to :order
  validates_uniqueness_of :order_id, scope: %i[item_id item_type price]
  # 修改报价单后，计算合计
  before_save :calculate_total

  # 订单状态：0.部件 1.配件 2.工艺
  enum item_type: %i[unit part craft]

  def self.item_type
    [%w[部件 unit], %w[配件 part], %w[工艺 craft]]
  end

  def item_type_name
    case item_type
    when 'unit' then '部件'
    when 'part' then '配件'
    when 'craft' then '工艺'
    else
      '未知状态'
    end
  end

  def calculate_total
    self.total = (price * number).round
    @order = order

    # 更新子订单金额
    sum_units = 0
    # 将子订单的所有部件按是否"自定义报价"分组 {true: 自定义报价部件; false: 正常拆单部件}
    group_units = @order.units.group_by(&:is_custom)
    # 自定义报价中的部件 尺寸 不参与计算
    sum_units += group_units[true].map { |u| u.number * u.price }.sum if group_units[true]
    # 正常拆单部件 尺寸 参与计算
    sum_units += group_units[false].map { |u| u.size.split(/[xX*×]/).map(&:to_i).inject(1) { |result, item| result * item } / (1000 * 1000).to_f * u.number * u.price }.sum if group_units[false]
    # 计算 配件 金额
    sum_parts = @order.parts.map { |p| p.number * p.price }.sum
    # 计算 工艺 金额
    sum_crafts = @order.crafts.map { |c| c.number * c.price }.sum
    # 子订单金额 = 子订单部件合计 + 子订单配件合计 + 子订单工艺费合计
    @order.update!(price: sum_units + sum_parts + sum_crafts)

    # 更新总订单金额
    indent = @order.indent
    # 总订单 -- 所有子订单金额合计
    indent_amount = indent.orders.pluck(:price).sum
    # 总订单 -- 所有收入金额合计
    indent_income = indent.incomes.pluck(:money).sum
    # 总订单： 金额合计 = 所有子订单金额合计，  欠款合计 = 所有子订单金额合计 - 所有收入金额合计
    indent.update!(amount: indent_amount, arrear: indent_amount - indent_income)
  end
end
