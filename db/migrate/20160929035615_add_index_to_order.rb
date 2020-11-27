class AddIndexToOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :index, :integer
  end
end
