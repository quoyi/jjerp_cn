class Indent < ActiveRecord::Base
  has_many :orders
  belongs_to :agent
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

end
