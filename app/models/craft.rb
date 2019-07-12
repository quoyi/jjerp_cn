class Craft < ActiveRecord::Base
  belongs_to :order
  belongs_to :craft_category
  before_save :generate_full_name

  def generate_full_name
    self.full_name = CraftCategory.find_by_id(craft_category_id).full_name unless full_name.present?
  end
end

# == Schema Information
#
# Table name: crafts
#
#  id                :integer          not null, primary key
#  deleted           :boolean          default(FALSE)
#  full_name         :string(255)      default("")
#  note              :string(255)
#  number            :decimal(8, 2)    default(1.0), not null
#  price             :decimal(8, 2)    default(0.0), not null
#  status            :boolean
#  uom               :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  craft_category_id :integer
#  order_id          :integer
#
# Indexes
#
#  index_crafts_on_full_name  (full_name)
#
