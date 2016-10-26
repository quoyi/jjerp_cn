class EditIndentAddress < ActiveRecord::Migration
  def change
    rename_column :indents, :address, :delivery_address
  end
end
