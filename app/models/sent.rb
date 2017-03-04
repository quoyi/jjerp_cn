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
