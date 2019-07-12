class UserCategory < ActiveRecord::Base
end

# == Schema Information
#
# Table name: user_categories
#
#  id         :integer          not null, primary key
#  deleted    :boolean          default(FALSE)
#  name       :string(255)      not null
#  nick       :string(255)      default("")
#  serial     :string(255)      not null
#  visible    :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_categories_on_name    (name)
#  index_user_categories_on_serial  (serial)
#
