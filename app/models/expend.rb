# == Schema Information
#
# Table name: expends
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  bank_id    :integer
#  reason     :string(255)
#  money      :decimal(12, 2)   default(0.0)
#  username   :string(255)
#  expend_at  :datetime
#  status     :integer
#  note       :string(255)
#  deleted    :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Expend < ActiveRecord::Base
  belongs_to :bank
end
