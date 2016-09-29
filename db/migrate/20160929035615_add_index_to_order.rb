class AddIndexToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :index, :integer
  end
end
