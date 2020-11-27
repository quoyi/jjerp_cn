class Task < ApplicationRecord
end

# == Schema Information
#
# Table name: tasks
#
#  id           :integer          not null, primary key
#  area         :decimal(9, 6)
#  availability :decimal(8, 2)
#  deleted      :boolean          default(FALSE)
#  item_type    :string(255)
#  mix_status   :integer          default(0)
#  number       :integer
#  sequence     :string(255)
#  state        :integer
#  work         :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  item_id      :integer
#  order_id     :integer
#
# Indexes
#
#  index_tasks_on_item_id   (item_id)
#  index_tasks_on_order_id  (order_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#
