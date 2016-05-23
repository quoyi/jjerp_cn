class CreateDepartments < ActiveRecord::Migration
  def change
    # 部门
    create_table :departments do |t|
      t.string :name, null: false, index: true, uniq: true
      t.string  :full_name, null: false, index: true, default: '', uniq: true # 部门名称
      t.references :user # 部门经理
      t.integer :total    # 部门人数
      t.text :desc       # 部门的职能描述
      t.boolean :deleted, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
