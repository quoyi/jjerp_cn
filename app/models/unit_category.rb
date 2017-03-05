# == Schema Information
#
# Table name: unit_categories
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  note       :string(255)
#  deleted    :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UnitCategory < ActiveRecord::Base
  has_many :unit
  validates :name, uniqueness: true
end
