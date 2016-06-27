class Offer < ActiveRecord::Base
  belongs_to :indent
  belongs_to :order
  validates_uniqueness_of :order_id, scope: [:item_id, :item_type, :price]

  #订单状态：0.部件 1.配件 2.工艺
  enum item_type: [:unit, :part, :craft]

  def self.item_type
    [['部件', 'unit'], ['配件', 'part'], ['工艺', 'craft']]
  end

  def item_type_name
    case item_type
      when 'unit' then '部件'
      when 'part' then '配件'
      when 'craft' then '工艺'
    else
      "未知状态"
    end
  end
end
