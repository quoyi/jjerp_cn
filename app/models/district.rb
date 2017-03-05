# == Schema Information
#
# Table name: districts
#
#  id      :integer          not null, primary key
#  city_id :integer
#  name    :string(255)
#

class District < ActiveRecord::Base
end
