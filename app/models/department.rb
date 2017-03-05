# == Schema Information
#
# Table name: departments
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  full_name  :string(255)      default(""), not null
#  user_id    :integer
#  total      :integer
#  desc       :text(65535)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Department < ActiveRecord::Base
end
