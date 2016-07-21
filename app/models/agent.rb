class Agent < ActiveRecord::Base
  has_many :indents
  validates :name, uniqueness: true
  validates_uniqueness_of :full_name
  #validates :full_name, uniqueness: {scope: :name}
end
