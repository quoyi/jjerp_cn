class Material < ActiveRecord::Base
  belongs_to :material_category
  validates_presence_of :serial, :name, :ply, :texture, :face, :color, :buy, :sell, :supply_id
end
