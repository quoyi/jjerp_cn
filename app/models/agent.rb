class Agent < ActiveRecord::Base
  has_many :indents
  has_many :orders
  validates :name, uniqueness: true
  validates_uniqueness_of :full_name
  before_save :generate_address
  #validates :full_name, uniqueness: {scope: :name}
  #

  # def delivery_address
    
  #   # [ChinaCity.get(self.province), ChinaCity.get(self.city), ChinaCity.get(self.district), self.town, self.address].join('')
  # end

  protected
  def generate_address
    self.address = Province.find(self.province).try(:name) if self.province.present?
    self.address += City.find(self.city).try(:name) if self.city.present?
    self.address += District.find(self.district).try(:name) if self.district.present?
    self.address += self.town
    # if self.city.present?
    #   tmp_address = ""
    #   city_name = ChinaCity.get(city)
    #   binding.pry
    #   if (city_name =~ /(自治州|单位)$/).present?
    #     tmp_address = ChinaCity.get(province) + ChinaCity.get(district)
    #   elsif (city_name =~ /(市辖区|县)$/).present?
    #     tmp_address = ChinaCity.get(province) + (district.present? ? ChinaCity.get(district) : "")
    #   end
    #   # tmp_address = city_name.gsub("地区", "")
    # else
    #   tmp_address = ChinaCity.get(province)
    # end
    tmp_address = ""
    if self.city.present?
      city_name = City.find(city).name
      if (city_name =~ /(自治州|区划)$/).present?
        tmp_address = Province.find(province).name.gsub("省", "") + city_name.gsub("土家族苗族自治州", "").gsub("省直辖县级行政区划", "")
        if self.district.present?
          tmp_address = city_name.gsub("土家族苗族自治州", "").gsub("省直辖县级行政区划", "") + District.find(district).name.gsub("市", "").gsub("县", "").gsub("林区", "")
        end
      elsif (city_name =~ /(市辖区|县)$/).present?
        tmp_address = Province.find(province).name
        if self.district.present?
          tmp_district = District.find(district).name
          tmp_address = tmp_address + (tmp_district.length > 2 ? tmp_district.gsub("县", "") : tmp_district)
        end
      else
        tmp_address = Province.find(province).name.gsub("省", "") + city_name
        if self.district.present?
          tmp_district =  District.find(district).name.gsub("市辖区", "").gsub("土家族自治县", "")
          tmp_address = city_name + (tmp_district.length > 2 ? tmp_district.gsub("区", "").gsub("县", "") : tmp_district)
        end
      end
      tmp_address = tmp_address.gsub("市", "").gsub("地区", "")
    else
      tmp_address = Province.find(province).name
    end
    self.delivery_address = tmp_address
  end
end