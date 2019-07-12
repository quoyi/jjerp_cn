# == Schema Information
#
# Table name: crafts
#
#  id                :integer          not null, primary key
#  order_id          :integer
#  craft_category_id :integer
#  full_name         :string(255)      default("")
#  uom               :string(255)
#  price             :decimal(8, 2)    default(0.0), not null
#  number            :decimal(8, 2)    default(1.0), not null
#  note              :string(255)
#  status            :boolean
#  deleted           :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Craft < ActiveRecord::Base
  belongs_to :order
  belongs_to :craft_category
  before_save :generate_full_name

  def generate_full_name
    self.full_name = CraftCategory.find_by_id(craft_category_id).full_name unless full_name.present?
  end
end
