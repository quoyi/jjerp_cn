class Order < ApplicationRecord
  include OffersHelper
  belongs_to :order_category
  belongs_to :indent
  belongs_to :agent
  has_many :incomes, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :units, dependent: :destroy
  has_many :parts, dependent: :destroy
  has_many :crafts, dependent: :destroy
  has_many :packages, dependent: :destroy
  has_one :sent, as: :owner, dependent: :destroy # 一个子订单只有一个发货信息
  # 发货时间需在十天以后
  # validate :validate_require_time
  # validates_uniqueness_of :name
  before_create :generate_order_code
  before_save :order_money_to_int
  # after_update :update_indent_and_agent # 更新子订单时，同步更新总订单、代理商金额
  accepts_nested_attributes_for :units, allow_destroy: true
  accepts_nested_attributes_for :parts, reject_if: :social_rejectable?, allow_destroy: true
  accepts_nested_attributes_for :crafts, allow_destroy: true

  validates :order_category_id, presence: true
  scope :agent_amount, ->(agent_id) { where(agent_id: agent_id).pluck(:price).sum.round(2) }
  scope :agent_arrear, ->(agent_id) { where(agent_id: agent_id).pluck(:arrear).sum.round(2) }
  scope :not_sent, -> { where(status: statuses[:packaged]) }
  # scope :not_sent, -> do
  #   result = []
  #   all.group_by{|o|o.indent_id}.each_pair do |k, v|
  #     group = {}
  #     indent = Indent.find(k)
  #     min_status = Indent.statuses[:offered]..Indent.statuses[:packaged]
  #     max_status = Indent.statuses[:packaged]..Indent.statuses[:sent]
  #     if max_status.include?(indent.status) && min_status.include?(indent.status)

  #     end
  #     group[:indent] = Indent.find(k)
  #     group[:orders] = v
  #     result.push(group)
  #   end
  #   result
  # end

  # 订单状态：0.报价中 1.已报价 2.生产中 3.已入库 4.已发货
  enum status: %i[offering offered producing packaged sending sent over]

  def self.status
    [%w[报价中 offering], %w[已报价 offered], %w[生产中 producing], %w[已入库 packaged], %w[发货中 sending], %w[已发货 sent], %w[已完成 over]]
  end

  def status_name
    case status
    when 'offering' then '报价中'
    when 'offered' then '已报价'
    when 'producing' then '生产中'
    when 'packaged' then '已入库'
    when 'sending' then '发货中'
    when 'sent' then '已发货'
    when 'over' then '已完成'
    else
      '未知状态'
    end
  end

  def income_status
    if price.zero?
      '未报价'
    elsif incomes.pluck(:money).sum >= price
      '全款'
    elsif incomes.pluck(:money).sum.zero?
      '未打款'
    else
      '定金'
    end
  end

  # 类型：0.正常单 1.补单 3.加急单  4.批量单
  enum oftype: %i[normal add fast batch]

  def self.oftype
    [%w[正常单 normal], %w[补单 add], %w[加急单 fast], %w[批量单 batch]]
  end

  def oftype_name
    case oftype
    when 'normal' then '正常单'
    when 'add' then '补单'
    when 'fast' then '加急单'
    when 'batch' then '批量单'
    else
      '未知类型'
    end
  end

  # 判断订单的处理人是否为 user
  def handler?(user)
    handler != 0 && handler != user.id
  end

  def validate_require_time
    # (Time.now.to_i - updated_at.to_i)/86400 <= 3
    time =  created_at || Time.now
    errors.add(:require_time, '发货时间需在十天以后') if (Date.parse(require_time.to_s) - Date.parse(time.to_s)).to_i < 10
  end

  def generate_order_code
    self.agent_id = indent.agent_id
    self.delivery_address = indent.delivery_address || agent.delivery_address
    current_year = Time.now.year.to_s
    current_month = Time.now.mon.to_s
    agent_order = Order.where("name like '#{current_year}%-#{current_month}-%'").last
    agent_orders_count = if agent_order.present?
                           agent_order.name.split('-').last.to_i
                         else
                           0
                         end
    temp_hash = { '1': 'w', '2': 'y', '3': 'm', '4': 'p', '5': 'q' }

    tmp = case Order.oftypes[oftype]
          when 1 then "补#{temp_hash[order_category_id.to_s.to_sym].try(:upcase)}"
          when 2 then "急#{temp_hash[order_category_id.to_s.to_sym].try(:upcase)}"
          when 3 then "批#{temp_hash[order_category_id.to_s.to_sym].try(:upcase)}"
          else
            temp_hash[order_category_id.to_s.to_sym].try(:upcase).to_s
          end
    self.index = agent_orders_count + 1
    self.name =  current_year + tmp + "-#{current_month}-" + index.to_s
    # self.serial = current_year + "-" + current_month + self.index.to_s
  end

  def order_money_to_int
    self.arrear = arrear.round
    self.price = price.round
    self.status = Order.statuses[:offering] if units.count < 1 && parts.count < 1 && crafts.count < 1
    number = 0
    units.each do |unit|
      # 计算非背板板料面积
      next if unit.backboard?

      number += if unit.size.blank?
                  unit.number
                else
                  unit.size.split(/[xX*×]/).map(&:to_i).inject(1) { |result, item| result *= item } / (1000 * 1000).to_f * unit.number
                end
    end
    self.material_number = number
  end

  private

  def social_rejectable?(att)
    att['number'].blank? && !att['id']
  end

  # # 更新订单时，同步更新代理商金额
  # def update_indent_and_agent
  #   indent = self.indent
  #   agent = indent.agent
  #   order_amount = self.price
  #   # 单个总订单金额合计
  #   indent_amount = indent.orders.map(&:price).sum
  #   # 单个总订单收款合计
  #   income_amount = indent.incomes.map(&:money).sum
  #   # 单个总订单金额合计 = 修改后的所有子订单金额合计  ||  单个总订单欠款合计 = 单个总订单金额合计 - 收款合计
  #   indent.update_attributes(amount: indent_amount, arrear: indent_amount - income_amount)
  #   # 代理商欠款 = 所有总订单金额 - 所有已收款
  #   agent_arrear = agent.indents.map{ |i| i.orders.map(&:price).sum }.sum
  #   agent.update_attributes(arrear: agent_arrear)
  # end
end

# == Schema Information
#
# Table name: orders
#
#  id                    :integer          not null, primary key
#  arrear                :decimal(12, 2)   default(0.0)
#  color                 :integer          default(0), not null
#  customer              :string(255)
#  deleted               :boolean          default(FALSE), not null
#  delivery_address      :string(255)      default(""), not null
#  handler               :integer          default(0), not null
#  height                :integer          default(1), not null
#  index                 :integer
#  is_use_order_material :boolean          default(FALSE)
#  length                :integer          default(1), not null
#  material_number       :decimal(8, 2)    default(0.0), not null
#  material_price        :decimal(8, 2)    default(0.0)
#  name                  :string(255)      default(""), not null
#  note                  :string(255)
#  number                :integer          default(1), not null
#  oftype                :integer          default(0), not null
#  over_at               :datetime
#  package_num           :integer          default(0), not null
#  packaged_at           :datetime
#  ply                   :integer          default(0), not null
#  price                 :decimal(12, 2)   default(0.0)
#  produced_at           :datetime
#  sent_at               :datetime
#  status                :integer          default(0), not null
#  texture               :integer          default(0), not null
#  width                 :integer          default(1), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  agent_id              :integer
#  indent_id             :integer          not null
#  order_category_id     :integer          default(1), not null
#
# Indexes
#
#  index_orders_on_agent_id   (agent_id)
#  index_orders_on_indent_id  (indent_id)
#  index_orders_on_name       (name) UNIQUE
#
