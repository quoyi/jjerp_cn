# == Schema Information
#
# Table name: templates
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  creator    :integer          not null
#  price      :decimal(8, 2)    default(0.0)
#  times      :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Template < ActiveRecord::Base
end
