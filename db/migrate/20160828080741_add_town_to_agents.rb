class AddTownToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :town, :string
  end
end
