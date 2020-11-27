class Department < ApplicationRecord
end

# == Schema Information
#
# Table name: departments
#
#  id         :integer          not null, primary key
#  deleted    :boolean          default(FALSE)
#  desc       :text(65535)
#  full_name  :string(255)      default(""), not null
#  name       :string(255)      not null
#  total      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_departments_on_full_name  (full_name)
#  index_departments_on_name       (name)
#
