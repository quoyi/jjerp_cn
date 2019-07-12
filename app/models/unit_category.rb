class UnitCategory < ActiveRecord::Base
  has_many :unit
  validates :name, uniqueness: true
end

# == Schema Information
#
# Table name: unit_categories
#
#  id         :integer          not null, primary key
#  deleted    :boolean          default(FALSE), not null
#  name       :string(255)      not null
#  note       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
