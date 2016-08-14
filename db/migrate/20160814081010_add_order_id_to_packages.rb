class AddOrderIdToPackages < ActiveRecord::Migration
  def change
    add_reference :packages, :order, index: true
  end
end