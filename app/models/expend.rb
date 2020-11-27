class Expend < ApplicationRecord
  belongs_to :bank
end

# == Schema Information
#
# Table name: expends
#
#  id         :integer          not null, primary key
#  deleted    :boolean          default(FALSE), not null
#  expend_at  :datetime
#  money      :decimal(12, 2)   default(0.0)
#  name       :string(255)
#  note       :string(255)
#  reason     :string(255)
#  status     :integer
#  username   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  bank_id    :integer
#
