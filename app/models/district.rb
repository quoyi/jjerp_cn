class District < ApplicationRecord
end

# == Schema Information
#
# Table name: districts
#
#  id      :integer          not null, primary key
#  name    :string(255)
#  city_id :integer
#
# Indexes
#
#  index_districts_on_city_id           (city_id)
#  index_districts_on_city_id_and_name  (city_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id)
#
