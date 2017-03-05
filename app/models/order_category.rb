# == Schema Information
#
# Table name: order_categories
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  note       :string(255)
#  deleted    :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OrderCategory < ActiveRecord::Base
  has_many :order
  validates :name, presence: true, uniqueness: true
end
