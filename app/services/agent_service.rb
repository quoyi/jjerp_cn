class AgentService < BaseService
  # 获取代理商信息
  def self.agent(agent_id)
    Agent.find(agent_id)
  end

  # 同步代理商信息
  def self.sync_status(agent)
    agent_earning = Income.agent_earning(agent.id)
    agent_order_amount =  Order.agent_amount(agent.id)
    agent.update(balance: agent_earning,
                 arrear: agent_earning - agent_order_amount,
                 history: agent_order_amount)
  end
end
