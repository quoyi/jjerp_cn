# == Schema Information
#
# Table name: orders
#
#  id                    :integer          not null, primary key
#  indent_id             :integer          not null
#  name                  :string(255)      default(""), not null
#  order_category_id     :integer          default(1), not null
#  customer              :string(255)
#  ply                   :integer          default(0), not null
#  texture               :integer          default(0), not null
#  color                 :integer          default(0), not null
#  length                :integer          default(1), not null
#  width                 :integer          default(1), not null
#  height                :integer          default(1), not null
#  number                :integer          default(1), not null
#  price                 :decimal(12, 2)   default(0.0)
#  arrear                :decimal(12, 2)   default(0.0)
#  material_price        :decimal(8, 2)    default(0.0)
#  status                :integer          default(0), not null
#  oftype                :integer          default(0), not null
#  package_num           :integer          default(0), not null
#  note                  :string(255)
#  delivery_address      :string(255)      default(""), not null
#  deleted               :boolean          default(FALSE), not null
#  is_use_order_material :boolean          default(FALSE)
#  agent_id              :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  index                 :integer
#  handler               :integer          default(0), not null
#  material_number       :decimal(8, 2)    default(0.0), not null
#  produced_at           :datetime
#  packaged_at           :datetime
#  sent_at               :datetime
#  over_at               :datetime
#

class Order < ActiveRecord::Base
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
  has_one :sent, as: :owner, dependent: :destroy #一个子订单只有一个发货信息
  # 发货时间需在十天以后
  # validate :validate_require_time
  #validates_uniqueness_of :name
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


  #订单状态：0.报价中 1.已报价 2.生产中 3.已入库 4.已发货
  enum status: [:offering, :offered, :producing, :packaged, :sending, :sent, :over]

  def self.status
    [['报价中', 'offering'], ['已报价', 'offered'], ['生产中', 'producing'], ["已入库", "packaged"], ['发货中', 'sending'], ['已发货', 'sent'], ['已完成', 'over']]
  end

  def status_name
    case status
      when 'offering' then '报价中'
      when 'offered' then '已报价'
      when 'producing' then '生产中'
      when 'packaged' then '已入库'
      when "sending" then '发货中'
      when 'sent' then '已发货'
      when 'over' then '已完成'
    else
      "未知状态"
    end
  end

  def income_status
    if self.price == 0
      '未报价'
    else
      if self.incomes.pluck(:money).sum >= self.price
        '全款'
      elsif self.incomes.pluck(:money).sum.to_i == 0
        '未打款'
      else
        '定金'
      end
    end
  end

  #类型：0.正常单 1.补单 3.加急单  4.批量单
  enum oftype: [:normal, :add, :fast, :batch]

  def self.oftype
    [['正常单', 'normal'], ['补单', 'add'], ['加急单', 'fast'], ["批量单", "batch"]]
  end

  def oftype_name
    case oftype
      when 'normal' then '正常单'
      when 'add' then '补单'
      when 'fast' then '加急单'
      when 'batch' then '批量单'
    else
      "未知类型"
    end
  end

  # 判断订单的处理人是否为 user
  def handler?(user)
    handler != 0 && handler != user.id
  end

  def validate_require_time
    # (Time.now.to_i - updated_at.to_i)/86400 <= 3
    time =  self.created_at || Time.now
    if (Date.parse(self.require_time.to_s) - Date.parse(time.to_s)).to_i < 10
      self.errors.add(:require_time, '发货时间需在十天以后')
    end
  end

  def generate_order_code
    self.agent_id = self.indent.agent_id
    self.delivery_address = self.indent.delivery_address || self.agent.delivery_address
    current_year = Time.now.year.to_s
    current_month = Time.now.mon.to_s
    agent_order = Order.where("name like '#{current_year}%-#{current_month}-%'").last
    if agent_order.present?
      agent_orders_count = agent_order.name.split("-").last.to_i
    else
      agent_orders_count = 0
    end
    temp_hash = {'1': 'w', '2': 'y', '3': 'm', '4': 'p', '5': 'q'}

    tmp = case Order.oftypes[oftype]
          when 1 then "补#{temp_hash[order_category_id.to_s.to_sym].try(:upcase)}"
          when 2 then "急#{temp_hash[order_category_id.to_s.to_sym].try(:upcase)}"
          when 3 then "批#{temp_hash[order_category_id.to_s.to_sym].try(:upcase)}"
          else
            "#{temp_hash[order_category_id.to_s.to_sym].try(:upcase)}"
          end
    self.index = agent_orders_count + 1
    self.name =  current_year + tmp + "-#{current_month}-" + self.index.to_s
    # self.serial = current_year + "-" + current_month + self.index.to_s
  end

  def order_money_to_int
    self.arrear = self.arrear.round
    self.price = self.price.round
    self.status = Order.statuses[:offering] if self.units.count < 1 && self.parts.count < 1 && self.crafts.count < 1
    number = 0
    self.units.each do |unit|
      # 计算非背板板料面积
      unless unit.backboard?
        if unit.size.blank?
          number += unit.number
        else
          number += unit.size.split(/[xX*×]/).map(&:to_i).inject(1){|result, item| result*=item}/(1000*1000).to_f * unit.number
        end
      end
    end
    self.material_number = number
  end

  def caseType(type, str)

  end

  private 
  def social_rejectable?(att)
    att['number'].blank? && !att["id"]
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
