class Sent < ApplicationRecord
  belongs_to :sent_list
  belongs_to :owner, polymorphic: true
  after_destroy :sync_order_status

  # 更新时，才验证是否指定 发货时间、物流号
  # validates_presence_of :sent_at, on: :update, message: '发货时间必须填写'
  # validates_presence_of :logistics_code, on: :update, message: "发货回执单号必须填写"

  private

  def sync_order_status
    owner.packaged!
    owner.indent.packaged! if owner.name == Order
  end
end

# == Schema Information
#
# Table name: sents
#
#  id             :integer          not null, primary key
#  area           :string(255)
#  collection     :decimal(12, 2)   default(0.0)
#  contact        :string(255)      not null
#  cupboard       :integer          default(0)
#  door           :integer          default(0)
#  logistics      :string(255)      default(""), not null
#  logistics_code :string(255)      default(""), not null
#  name           :string(255)
#  owner_type     :string(255)      not null
#  part           :integer          default(0)
#  receiver       :string(255)      not null
#  robe           :integer          default(0)
#  sent_at        :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  owner_id       :integer          not null
#  sent_list_id   :integer
#
