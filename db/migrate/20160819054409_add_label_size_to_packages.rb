class AddLabelSizeToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :label_size, :integer, defaule: 0
  end
end
