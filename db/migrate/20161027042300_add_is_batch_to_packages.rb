class AddIsBatchToPackages < ActiveRecord::Migration[6.0]
  def change
    add_column :packages, :is_batch, :boolean, null: false, default: false
  end
end
