class Order < ActiveRecord::Base
  belongs_to :order_category
  validates_presence_of :indent_id, :name, :order_category_id, :number, :oftype, :status
end
