class SentList < ActiveRecord::Base
  has_many :sents

  before_create :generate_code

  def generate_code
    current_month = Time.now.strftime('%Y%m')
    agent_last_order = SentList.where("name like 'FH#{current_month}-%'").order(:created_at).last

    agent_last_order_index = agent_last_order.name.split("-").last.to_i if agent_last_order.present?
    self.name = "FH" + current_month + "-" + (agent_last_order_index+1).to_s
  end
end
