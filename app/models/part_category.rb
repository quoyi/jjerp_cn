# == Schema Information
#
# Table name: part_categories
#
#  id         :integer          not null, primary key
#  parent_id  :integer          default(1)
#  name       :string(255)      default(""), not null
#  buy        :decimal(8, 2)    default(0.0)
#  price      :decimal(8, 2)    default(0.0)
#  store      :integer          default(0), not null
#  uom        :string(255)
#  brand      :string(255)
#  supply_id  :integer
#  note       :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

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

  def children
    PartCategory.where(parent_id: id)
  end

  def parent
    PartCategory.where(id: parent_id)
  end

  def self.root
    self.where(parent_id: 0)
  end

end
