# == Schema Information
#
# Table name: craft_categories
#
#  id         :integer          not null, primary key
#  full_name  :string(255)      default(""), not null
#  uom        :string(255)      default("")
#  price      :decimal(8, 2)    default(0.0), not null
#  note       :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CraftCategory < ActiveRecord::Base
  attr_accessor :reset
  has_many :crafts
end
