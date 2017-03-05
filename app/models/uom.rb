# == Schema Information
#
# Table name: uoms
#
#  id         :integer          not null, primary key
#  name       :string(255)      default(""), not null
#  val        :string(255)
#  note       :string(255)      default("")
#  deleted    :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Uom < ActiveRecord::Base
  validates_uniqueness_of :name
end
