class Supply < ActiveRecord::Base
  has_many :part
  has_many :unit
  has_many :material
  validates_presence_of :name, :full_name
  validates :name, uniqueness: true
  validates :full_name, uniqueness: { scope: :name }
end

# == Schema Information
#
# Table name: supplies
#
#  id           :integer          not null, primary key
#  address      :string(255)
#  bank_account :string(255)
#  deleted      :boolean          default(FALSE)
#  full_name    :string(255)      not null
#  mobile       :string(255)
#  name         :string(255)      not null
#  note         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_supplies_on_full_name  (full_name)
#  index_supplies_on_name       (name)
#
