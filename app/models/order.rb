class Order < ActiveRecord::Base
  belongs_to :order_category
  belongs_to :indent
  validates_presence_of :indent_id, :name, :order_category_id, :number, :oftype, :status
  # 发货时间需在十天以后
  validate :validate_require_time


  #订单状态：0.正常 1.异常 2.其他
  enum status: [:general, :error, :other]

  def self.status
    [['正常', 'general'], ['异常', 'error'], ['其他', 'other']]
  end

  def status_name
    case status
      when 'general' then '正常'
      when 'error' then '异常'
      when 'other' then '其他'
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
end
