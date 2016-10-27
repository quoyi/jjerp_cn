class AddIsBatchToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :is_batch, :boolean, null: false, default: false
  end
end
