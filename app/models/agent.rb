class Agent < ActiveRecord::Base
  has_many :indents
  has_many :orders
  validates :name, uniqueness: true
  validates_uniqueness_of :full_name
  #validates :full_name, uniqueness: {scope: :name}
  #

  def full_address
    [ChinaCity.get(self.province), ChinaCity.get(self.city), ChinaCity.get(self.district), self.town, self.address].join('')
  end

end
