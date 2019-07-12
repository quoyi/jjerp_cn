class PartCategory < ActiveRecord::Base
  # 定义自连接
  has_many :subobject, class_name: 'PartCategory', foreign_key: 'parent_id'
  has_many :part
  belongs_to :supply
  belongs_to :parent, class_name: 'PartCategory'
  validates :name, presence: true
  # validates :name, uniqueness: {scope: :parent_id}
  before_save :set_part_category

  def set_part_category
    # 设置基本类型的 parent_id
    self.parent_id = 0 unless parent_id
  end

  def children
    PartCategory.where(parent_id: id)
  end

  def parent
    PartCategory.where(id: parent_id)
  end

  def self.root
    where(parent_id: 0)
  end
end

# == Schema Information
#
# Table name: part_categories
#
#  id         :integer          not null, primary key
#  brand      :string(255)
#  buy        :decimal(8, 2)    default(0.0)
#  deleted    :boolean          default(FALSE)
#  name       :string(255)      default(""), not null
#  note       :string(255)
#  price      :decimal(8, 2)    default(0.0)
#  store      :integer          default(0), not null
#  uom        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :integer          default(1)
#  supply_id  :integer
#
# Indexes
#
#  index_part_categories_on_name       (name) UNIQUE
#  index_part_categories_on_supply_id  (supply_id)
#
