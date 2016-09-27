class Craft < ActiveRecord::Base
  belongs_to :order
  belongs_to :craft_category
  before_save :generate_full_name

  def generate_full_name
    self.full_name = CraftCategory.find_by_id(self.craft_category_id).full_name unless full_name.present?
  end

end
