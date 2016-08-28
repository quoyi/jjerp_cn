class Order < ActiveRecord::Base
  include OffersHelper
  belongs_to :order_category
  belongs_to :indent
  belongs_to :agent
  has_many :incomes
  has_many :offers, dependent: :destroy
  has_many :units, dependent: :destroy
  has_many :parts, dependent: :destroy
  has_many :crafts, dependent: :destroy
  has_many :packages, dependent: :destroy
  has_one :sent, as: :owner, dependent: :destroy #一个子订单只有一个发货信息
  # 发货时间需在十天以后
  # validate :validate_require_time
  validates_uniqueness_of :name
  before_create :generate_order_code
  accepts_nested_attributes_for :units, allow_destroy: true
  accepts_nested_attributes_for :parts, allow_destroy: true
  accepts_nested_attributes_for :crafts, allow_destroy: true

  #订单状态：0.报价中 1.已报价 2.生产中 3.已入库 4.已发货
  enum status: [:offering, :offered, :producing, :packaged, :sending, :sent]

  def self.status
    [['报价中', 'offering'], ['已报价', 'offered'], ['生产中', 'producing'], ["已入库", "packaged"], ['发货中', 'sending'], ['已发货', 'sent']]
  end

  def status_name
    case status
      when 'offering' then '报价中'
      when 'offered' then '已报价'
      when 'producing' then '生产中'
      when 'packaged' then '已入库'
      when "sending" then '发货中'
      when 'sent' then '已发货'
    else
      "未知状态"
    end
  end

  def income_status
    if self.incomes.pluck(:money).sum >= self.price
      '全款'
    elsif self.incomes.pluck(:money).sum.to_i == 0
      '未打款'
    else
      '定金'
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

  def validate_require_time
    # (Time.now.to_i - updated_at.to_i)/86400 <= 3
    time =  self.created_at || Time.now
    if (Date.parse(self.require_time.to_s) - Date.parse(time.to_s)).to_i < 10
      self.errors.add(:require_time, '发货时间需在十天以后')
    end
  end

  def generate_order_code
    self.agent_id = self.indent.agent_id
    self.delivery_address = self.agent.full_address if self.delivery_address.blank?
    current_month = Time.now.strftime('%Y%m')
    agent_orders_count = Order.where("name like '#{current_month}-%'").count
    temp_hash = {'1': 'w', '2': '', '3': '', '4': 'y', '5': '', '6': '', '7': ''}

    tmp = case Order.oftypes[oftype]
          when 1 then "补#{temp_hash[order_category_id.to_s.to_sym].try(:upcase)}"
          when 2 then "急#{temp_hash[order_category_id.to_s.to_sym].try(:upcase)}"
          when 3 then "批#{temp_hash[order_category_id.to_s.to_sym].try(:upcase)}"
          else
            "#{temp_hash[order_category_id.to_s.to_sym].try(:upcase)}"
          end

    self.name =  current_month + "-" + tmp + "-" + (agent_orders_count+1).to_s
  end

  def caseType(type, str)

  end

end
