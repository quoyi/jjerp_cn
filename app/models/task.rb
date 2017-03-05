# == Schema Information
#
# Table name: tasks
#
#  id           :integer          not null, primary key
#  order_id     :integer
#  item_id      :integer
#  item_type    :string(255)
#  sequence     :string(255)
#  area         :decimal(9, 6)
#  mix_status   :integer          default(0)
#  availability :decimal(8, 2)
#  work         :integer          default(0)
#  state        :integer
#  number       :integer
#  deleted      :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Task < ActiveRecord::Base
end
