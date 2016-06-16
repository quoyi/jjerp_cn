class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :print_size, :string
  end
end
