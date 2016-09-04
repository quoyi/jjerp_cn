class Craft < ActiveRecord::Base
  belongs_to :order
  belongs_to :craft_category
end
