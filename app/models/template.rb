class Template < ActiveRecord::Base
end

# == Schema Information
#
# Table name: templates
#
#  id         :integer          not null, primary key
#  creator    :integer          not null
#  name       :string(255)      not null
#  price      :decimal(8, 2)    default(0.0)
#  times      :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_templates_on_name  (name)
#
