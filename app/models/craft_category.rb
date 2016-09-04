class CraftCategory < ActiveRecord::Base
  attr_accessor :reset
  has_many :crafts
end
