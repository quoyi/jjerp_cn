class CreatePackages < ActiveRecord::Migration[6.0]
  def change
    create_table :packages do |t|
      t.references :order, null: false, index: true # 子定单号
      t.string :unit_ids, default: ''
      t.string :part_ids, default: ''
      t.string :print_size
      t.integer :label_size, default: 0
    end
  end
end
