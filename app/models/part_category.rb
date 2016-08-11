class PartCategory < ActiveRecord::Base
  # 定义自连接
  has_many :subobject, class_name: 'PartCategory', foreign_key: 'parent_id'
  has_many :part
  belongs_to :supply
  belongs_to :parent, class_name: 'PartCategory'
  validates :name, presence: true
  #validates :name, uniqueness: {scope: :parent_id}
  before_save :set_part_category


  def set_part_category
    # 设置基本类型的 parent_id
    self.parent_id = 0 unless self.parent_id
  end
end
