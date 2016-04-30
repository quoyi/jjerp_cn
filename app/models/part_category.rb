class PartCategory < ActiveRecord::Base
  has_many :part
  validates_presence_of :name
end
