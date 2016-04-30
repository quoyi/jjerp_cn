class Supply < ActiveRecord::Base
  has_many :part
  validates_presence_of :serial, :name
end
