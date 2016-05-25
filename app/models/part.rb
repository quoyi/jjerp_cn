class Part < ActiveRecord::Base
  belongs_to :part_category
  belongs_to :supply
  belongs_to :order
  validates_presence_of :part_category_id, :name, :buy, :price, :supply_id

  before_save :generate_name

  def generate_name
    # 没有填写名称时，复制配件类型名称
    self.name = self.part_category.try(:name) if self.name.blank?
  end
end
