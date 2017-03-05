# == Schema Information
#
# Table name: cities
#
#  id          :integer          not null, primary key
#  province_id :integer
#  name        :string(255)
#

class City < ActiveRecord::Base
end
