# == Schema Information
#
# Table name: agents
#
#  id               :integer          not null, primary key
#  name             :string(255)      default(""), not null
#  province         :string(255)
#  city             :string(255)
#  district         :string(255)
#  town             :string(255)
#  address          :string(255)      default(""), not null
#  full_name        :string(255)      not null
#  contacts         :string(255)
#  mobile           :string(255)
#  e_account        :string(255)
#  fax              :string(255)
#  email            :string(255)
#  wechar           :string(255)
#  balance          :decimal(12, 2)   default(0.0), not null
#  arrear           :decimal(12, 2)   default(0.0), not null
#  history          :decimal(12, 2)   default(0.0), not null
#  logistics        :string(255)
#  order_condition  :integer
#  send_condition   :integer
#  cycle            :string(255)
#  note             :string(255)
#  deleted          :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  delivery_address :string(255)      default(""), not null
#

class Agent < ActiveRecord::Base
  has_many :indents
  has_many :orders
  has_many :incomes
  validates :name, uniqueness: true
  validates_uniqueness_of :mobile # 开发环境暂时取消此验证，否则无法模拟电话号码重复
  before_save :generate_address
  # attr_accessor :take_in, :take_out
  # validates :full_name, uniqueness: {scope: :name}
  #
  # def delivery_address
  #   # [ChinaCity.get(self.province), ChinaCity.get(self.city), ChinaCity.get(self.district), self.town, self.address].join('')
  # end

  protected

  def generate_address
    self.address = Province.find(province).try(:name) if province.present?
    self.address = address.to_s + City.find(city).try(:name) if city.present?
    self.address = address.to_s + District.find(district).try(:name) if district.present?
    self.address = address.to_s + town.to_s
    # if self.city.present?
    #   tmp_address = ""
    #   city_name = ChinaCity.get(city)
    #   if (city_name =~ /(自治州|单位)$/).present?
    #     tmp_address = ChinaCity.get(province) + ChinaCity.get(district)
    #   elsif (city_name =~ /(市辖区|县)$/).present?
    #     tmp_address = ChinaCity.get(province) + (district.present? ? ChinaCity.get(district) : "")
    #   end
    #   # tmp_address = city_name.gsub("地区", "")
    # else
    #   tmp_address = ChinaCity.get(province)
    # end
    tmp_address = ''
    province_name = Province.find(province).name.gsub('省', '')
    if city.present?
      city_name = City.find(city).name
      if (city_name =~ /(自治州|区划)$/).present?
        tmp_address =  province_name + city_name.gsub('土家族苗族自治州', '').gsub('省直辖县级行政区划', '')
        tmp_address = if district.present?
                        tmp_address + District.find(district).name.gsub('市', '').gsub('县', '').gsub('林区', '')
                      elsif town.present?
                        tmp_address + town
                      else
                        tmp_address
                      end
      elsif (city_name =~ /(市辖区|县)$/).present?
        tmp_address = province_name
        if district.present?
          tmp_district = District.find(district).name
          tmp_address += (tmp_district.length > 2 ? tmp_district.gsub('县', '') : tmp_district)
        elsif town.present?
          tmp_address += town
        else
          tmp_address = tmp_address
        end
      else
        tmp_address = province_name + city_name.gsub('市', '')
        if district.present?
          tmp_district = District.find(district).name.gsub('土家族自治县', '').gsub('市辖区', '')
          tmp_address += (tmp_district.length > 2 ? tmp_district.gsub('区', '').gsub('县', '') : tmp_district)
          tmp_address = (tmp_address.gsub(province_name, '') + town) if town.present?
        elsif town.present?
          tmp_address += town
        else
          tmp_address = tmp_address
        end
      end
      # tmp_address = tmp_address.gsub("市", "").gsub("地区", "")
    else
      tmp_address = province_name
      tmp_address += town if town.present?
    end
    self.delivery_address = tmp_address
  end
end
