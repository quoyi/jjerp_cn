class Order < ActiveRecord::Base
  belongs_to :order_category
  validates_presence_of :indent_id, :name, :order_category_id, :number, :oftype, :status


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
end
