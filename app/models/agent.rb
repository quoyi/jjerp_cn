class Agent < ActiveRecord::Base
  has_many :indents
  validates :name, uniqueness: true
  validates :full_name, uniqueness: {scope: :name}
end
