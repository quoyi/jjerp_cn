class IndentService < BaseService
  # 创建总订单
  def self.create(params)
    indent = Indent.create(params)
    agent = indent.agent
    agent.update(balance: agent.balance - indent.orders.pluck(:price).sum)
    indent
  end

  # 编辑
  def self.update(params)
    indent = Indent.find(params[:id])
    indent.update(params)
    sync_status(indent)
  end

  def self.sync_status(indent)
    indent.update(amount: indent.orders.pluck(:price).sum,
                  arrear: indent.orders.pluck(:price).sum,
                  status: indent.orders.map { |o| Order.statuses[o.status] }.min || 0)
  end
end
