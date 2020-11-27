class OrderCategory < ApplicationRecord
  has_many :order
  validates :name, presence: true, uniqueness: true
end

# == Schema Information
#
# Table name: order_categories
#
#  id         :integer          not null, primary key
#  deleted    :boolean          default(FALSE), not null
#  name       :string(255)      not null
#  note       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
