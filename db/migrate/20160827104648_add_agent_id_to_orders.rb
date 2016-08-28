class AddAgentIdToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :agent, index: true, foreign_key: true
  end
end
