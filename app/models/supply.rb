# == Schema Information
#
# Table name: supplies
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  full_name    :string(255)      not null
#  mobile       :string(255)
#  bank_account :string(255)
#  address      :string(255)
#  note         :string(255)
#  deleted      :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Supply < ActiveRecord::Base
  has_many :part
  has_many :unit
  has_many :material
  validates_presence_of :name, :full_name
  validates :name, uniqueness: true
  validates :full_name, uniqueness: {scope: :name}
end
