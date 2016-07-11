class Supply < ActiveRecord::Base
  has_many :part
  has_many :unit
  has_many :material
  validates_presence_of :name, :full_name
  validates :name, uniqueness: true
  validates :full_name, uniqueness: {scope: :name}
end
