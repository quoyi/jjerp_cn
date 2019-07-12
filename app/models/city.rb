class City < ActiveRecord::Base
end

# == Schema Information
#
# Table name: cities
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  province_id :integer
#
# Indexes
#
#  index_cities_on_province_id           (province_id)
#  index_cities_on_province_id_and_name  (province_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (province_id => provinces.id)
#
