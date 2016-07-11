class PartCategory < ActiveRecord::Base
  # 定义自连接
  has_many :subobject, class_name: 'PartCategory', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'PartCategory'
  has_many :part
  validates :name, presence: true
  validates :name, uniqueness: true
  before_save :set_part_category


  def set_part_category
    self.parent_id = 0 unless self.parent_id
  end
end
