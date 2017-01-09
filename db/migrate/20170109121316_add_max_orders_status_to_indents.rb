class AddMaxOrdersStatusToIndents < ActiveRecord::Migration
  def change
    add_column :indents, :max_status, :integer, null: false, default: 0
  end
end
