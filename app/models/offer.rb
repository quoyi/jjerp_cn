class Offer < ActiveRecord::Base

  #订单状态：0.部件 1.配件 2.工艺
  enum item: [:unit, :part, :craft]

  def self.item
    [['部件', 'unit'], ['配件', 'part'], ['工艺', 'craft']]
  end

  def item_name
    case item
      when 'unit' then '部件'
      when 'part' then '配件'
      when 'craft' then '工艺'
    else
      "未知状态"
    end
  end
end
