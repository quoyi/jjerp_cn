class Agent < ActiveRecord::Base
  has_many :indents
  has_many :orders
  validates :name, uniqueness: true
  validates_uniqueness_of :full_name
  before_save :generate_address
  #validates :full_name, uniqueness: {scope: :name}
  #

  def full_address
    [ChinaCity.get(self.province), ChinaCity.get(self.city), ChinaCity.get(self.district), self.town, self.address].join('')
  end

  protected
  def generate_address
    self.address = [ChinaCity.get(self.province), ChinaCity.get(self.city), ChinaCity.get(self.district)].join("")
  end
end
