class Craft < ActiveRecord::Base
  belongs_to :order

  attr_accessor :reset
end
