class Indent < ActiveRecord::Base
  has_many :order
  validates_presence_of :name, :agent_id, :ply, :texture, :color, :oftype
end
