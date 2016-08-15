class Package < ActiveRecord::Base
  belongs_to :order, dependent: :destroy
end
