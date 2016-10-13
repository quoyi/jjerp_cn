class Agent < ActiveRecord::Base
  has_many :indents
  has_many :orders
  validates :name, uniqueness: true
  validates_uniqueness_of :full_name
  before_save :generate_address
  #validates :full_name, uniqueness: {scope: :name}
  #

  def delivery_address
    if self.city.present?
      tmp_address = ""
      city_name = ChinaCity.get(city)
      if city_name =~ /(自治州|单位)$/
        if self.district.present?
          tmp_address = ChinaCity.get(district)
        else
          tmp_address = city_name
        end
      elsif city_name =~ /(市辖区|县)$/
        tmp_address = ChinaCity.get(province)
      end
      tmp_address.gsub("地区", "")
    else
      tmp_address = ChinaCity.get(province)
    end
    binding.pry
    tmp_address
    # [ChinaCity.get(self.province), ChinaCity.get(self.city), ChinaCity.get(self.district), self.town, self.address].join('')
  end

  protected
  def generate_address
    self.address = [ChinaCity.get(self.province), ChinaCity.get(self.city), ChinaCity.get(self.district)].join("") if self.address.blank?
  end
end
