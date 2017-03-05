# == Schema Information
#
# Table name: packages
#
#  id         :integer          not null, primary key
#  order_id   :integer          not null
#  unit_ids   :string(255)      default("")
#  part_ids   :string(255)      default("")
#  print_size :string(255)
#  label_size :integer          default(0)
#  is_batch   :boolean          default(FALSE), not null
#

class Package < ActiveRecord::Base
  belongs_to :order
end
