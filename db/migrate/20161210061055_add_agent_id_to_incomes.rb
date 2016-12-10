class AddAgentIdToIncomes < ActiveRecord::Migration
  def change
  	add_reference :incomes, :agent
  end
end
