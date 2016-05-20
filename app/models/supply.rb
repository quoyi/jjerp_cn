class Supply < ActiveRecord::Base
  has_many :part
  has_many :material
  validates_presence_of :serial, :name
end
