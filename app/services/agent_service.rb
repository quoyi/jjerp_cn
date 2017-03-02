class AgentService < BaseService
  # 获取代理商信息
  def self.agent(agent_id)
    Agent.find(agent_id)
  end

  # 同步代理商信息
  def self.sync_status(agent)
    orders_amount = agent.orders.pluck(:price).sum.round(2)
    agent.update(balance: agent.balance - orders_amount,
                 #  arrear: agent.arrear + orders_amount,
                 history: agent.balance + orders_amount)
  end
end
