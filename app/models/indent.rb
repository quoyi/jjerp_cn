class Indent < ActiveRecord::Base
  has_many :offers, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :incomes, dependent: :destroy
  has_many :packages, dependent: :destroy
  belongs_to :agent
  # 验证唯一性
  validates_uniqueness_of :name
  validates_presence_of :name, :agent_id, :customer, :verify_at, :require_at

  accepts_nested_attributes_for :orders, allow_destroy: true
  #下单条件：1.正常单  2.补单  3.加急单 4.批量单
  enum oftype: [:normal, :repair, :instancy, :batch]

  def self.oftype
    [['正常单', 'normal'], ['补单', 'repair'], ['加急单', 'instancy'], ['批量单', 'batch']]
  end

  def oftype_name
    case oftype
      when 'normal' then '正常单'
      when 'repair' then '补单'
      when 'instancy' then '加急单'
      when 'batch' then '批量单'
    else
      "未知状态"
    end
  end


  #状态：0.报价中 1.已报价 2.生产中 3.已入库 4.已发货
  enum status: [:offering, :offered, :producing, :packaged, :sent]

  def self.status
    [['报价中', 'offering'], ['已报价', 'offered'], ["生产中","producing"], ["已入库", "packaged"], ["已发货", "sent"]]
  end
  def status_name
    case status
      when 'offering' then '报价中'
      when 'offered' then '已报价'
      when 'checked' then '生产中'
      when "packaged" then '已入库'
      when "sent" then '已发货'
    else
      "未知状态"
    end
  end

end
