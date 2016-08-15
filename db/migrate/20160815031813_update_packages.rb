class UpdatePackages < ActiveRecord::Migration
  def change
    add_reference :packages, :order, index: true
    remove_reference :packages, :indent
  end
end
