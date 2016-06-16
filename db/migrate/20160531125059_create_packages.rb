class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.references :indent, null: false, index: true # 总定单号
      t.string :unit_ids
      t.string :part_ids
      t.string :print_size
    end
  end
end
