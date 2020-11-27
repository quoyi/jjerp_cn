class Uom < ApplicationRecord
  validates_uniqueness_of :name
end

# == Schema Information
#
# Table name: uoms
#
#  id         :integer          not null, primary key
#  deleted    :boolean          default(FALSE), not null
#  name       :string(255)      default(""), not null
#  note       :string(255)      default("")
#  val        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_uoms_on_name  (name) UNIQUE
#
