class AddAgentIdToIncomes < ActiveRecord::Migration[6.0]
  def change
  	add_reference :incomes, :agent
  end
end
