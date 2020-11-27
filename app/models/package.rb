class Package < ApplicationRecord
  belongs_to :order
end

# == Schema Information
#
# Table name: packages
#
#  id         :integer          not null, primary key
#  is_batch   :boolean          default(FALSE), not null
#  label_size :integer          default(0)
#  part_ids   :string(255)      default("")
#  print_size :string(255)
#  unit_ids   :string(255)      default("")
#  order_id   :integer          not null
#
# Indexes
#
#  index_packages_on_order_id  (order_id)
#
