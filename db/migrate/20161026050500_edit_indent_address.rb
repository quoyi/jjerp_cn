class EditIndentAddress < ActiveRecord::Migration[6.0]
  def change
    rename_column :indents, :address, :delivery_address
  end
end
