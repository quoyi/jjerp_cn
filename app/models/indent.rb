# == Schema Information
#
# Table name: indents
#
#  id               :integer          not null, primary key
#  name             :string(255)      not null
#  agent_id         :integer          not null
#  customer         :string(255)
#  verify_at        :date
#  require_at       :date
#  logistics        :string(255)
#  delivery_address :string(255)
#  status           :integer          default(0)
#  note             :string(255)
#  amount           :decimal(8, 2)    default(0.0)
#  arrear           :decimal(8, 2)    default(0.0)
#  total_history    :decimal(8, 2)    default(0.0)
#  total_arrear     :decimal(8, 2)    default(0.0)
#  deleted          :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  max_status       :integer          default(0), not null
#

class Indent < ActiveRecord::Base
  has_many :offers, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :order_parts # 虚构配件补单（ 实际为订单orders ）
  has_many :incomes, dependent: :destroy
  # has_many :packages, dependent: :destroy
  belongs_to :agent
  has_one :sent, as: :owner, dependent: :destroy # 一个总订单只有一个发货信息
  # 验证唯一性
  validates_uniqueness_of :name
  validates_presence_of :name, :agent_id, :customer, :verify_at, :require_at

  accepts_nested_attributes_for :orders, allow_destroy: true
  accepts_nested_attributes_for :offers, allow_destroy: true
  accepts_nested_attributes_for :order_parts, allow_destroy: true

  scope :not_sent, -> { where('status >= ? AND status <= ?', statuses[:packaged], statuses[:sent]) }

  # 下单条件：1.正常单  2.补单  3.加急单 4.批量单
  enum oftype: %i[normal repair instancy batch]

  def self.oftype
    [%w[正常单 normal], %w[补单 repair], %w[加急单 instancy], %w[批量单 batch]]
  end

  def oftype_name
    case oftype
    when 'normal' then '正常单'
    when 'repair' then '补单'
    when 'instancy' then '加急单'
    when 'batch' then '批量单'
    else
      '未知状态'
    end
  end

  # 状态：0.报价中 1.已报价 2.生产中 3.已入库 4.已发货
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

  def order_parts
    orders.where('order_category_id = 4 and ply = 0 and texture = 0 and color = 0')
  end
end
