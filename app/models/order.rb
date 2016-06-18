class Order < ActiveRecord::Base
  belongs_to :order_category
  belongs_to :indent
  has_many :units, dependent: :destroy
  has_many :parts, dependent: :destroy
  has_many :crafts, dependent: :destroy
  # 发货时间需在十天以后
  # validate :validate_require_time
  before_save :generate_order_code
  accepts_nested_attributes_for :units, allow_destroy: true
  accepts_nested_attributes_for :parts, allow_destroy: true
  accepts_nested_attributes_for :crafts, allow_destroy: true

  #订单状态：0.报价中 1.已报价 2.生产中 3.已入库 4.已发货
  enum status: [:offering, :offered, :producing, :packaged, :sent]

  def self.status
    [['报价中', 'offering'], ['已报价', 'offered'], ['生产中', 'producing'], ["已入库", "packaged"], ['已发货', 'sent']]
  end

  def status_name
    case status
      when 'offering' then '报价中'
      when 'offered' then '已报价'
      when 'producing' then '生产中'
      when 'packaged' then '已入库'
      when 'sent' then '已发货'
    else
      "未知状态"
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
    last_order = Order.where(indent_id: self.indent.id).order('name ASC').last
    order_index = last_order.present? ? (last_order.name.split(/-/).last.to_i + 1).to_s : 1
    self.name = self.indent.name + "-" + order_index.to_s
  end

end
