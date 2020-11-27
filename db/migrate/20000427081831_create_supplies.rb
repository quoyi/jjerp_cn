class CreateSupplies < ActiveRecord::Migration[6.0]
  def change
    # 供应商
    create_table :supplies do |t|
      t.string :name, null: false, index: true, uniq: true
      t.string :full_name, null: false, index: true # 供应商名称
      t.string :mobile # 电话
      t.string :bank_account #银行账户
      t.string :address # 地址
      t.string :note # 备注
      t.boolean :deleted, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
