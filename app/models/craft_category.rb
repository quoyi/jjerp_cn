class CraftCategory < ActiveRecord::Base
  attr_accessor :reset
  has_many :crafts
end

# == Schema Information
#
# Table name: craft_categories
#
#  id         :integer          not null, primary key
#  deleted    :boolean          default(FALSE)
#  full_name  :string(255)      default(""), not null
#  note       :string(255)
#  price      :decimal(8, 2)    default(0.0), not null
#  uom        :string(255)      default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_craft_categories_on_full_name  (full_name) UNIQUE
#
