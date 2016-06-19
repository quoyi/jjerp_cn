class CreateBanks < ActiveRecord::Migration
  def change
    # 银行信息
    create_table :banks do |t|
      t.string :name # 编号(或者开户人名称)
      t.string :bank_name # 开户银行名称
      t.string :bank_card # 银行卡号
      t.decimal :balance, precision: 8, scale: 2, default: 0 # 余额

      t.timestamps null: false
    end
  end
end
