class SentList < ActiveRecord::Base
  has_many :sents

  before_create :generate_code

  def generate_code
    current_month = Time.now.strftime('%Y%m')
    agent_orders_count = SentList.where("name like 'FH#{current_month}-%'").count

    self.name = "FH" + current_month + "-" + (agent_orders_count+1).to_s
  end
end
