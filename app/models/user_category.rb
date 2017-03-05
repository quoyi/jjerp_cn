# == Schema Information
#
# Table name: user_categories
#
#  id         :integer          not null, primary key
#  serial     :string(255)      not null
#  name       :string(255)      not null
#  nick       :string(255)      default("")
#  visible    :boolean          default(TRUE), not null
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserCategory < ActiveRecord::Base
end
