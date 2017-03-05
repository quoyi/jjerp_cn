# == Schema Information
#
# Table name: sents
#
#  id             :integer          not null, primary key
#  owner_id       :integer          not null
#  owner_type     :string(255)      not null
#  sent_list_id   :integer
#  name           :string(255)
#  sent_at        :datetime
#  area           :string(255)
#  receiver       :string(255)      not null
#  contact        :string(255)      not null
#  cupboard       :integer          default(0)
#  robe           :integer          default(0)
#  door           :integer          default(0)
#  part           :integer          default(0)
#  collection     :decimal(12, 2)   default(0.0)
#  logistics      :string(255)      default(""), not null
#  logistics_code :string(255)      default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Sent < ActiveRecord::Base
  belongs_to :sent_list
  belongs_to :owner, polymorphic: true
  after_destroy :sync_order_status

  # 更新时，才验证是否指定 发货时间、物流号
  # validates_presence_of :sent_at, on: :update, message: '发货时间必须填写'
  # validates_presence_of :logistics_code, on: :update, message: "发货回执单号必须填写"

  private

    def sync_order_status
      owner.packaged!
      owner.indent.packaged! if owner.name = Order
    end
end
