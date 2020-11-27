class CreateUnits < ActiveRecord::Migration[6.0]
  def change
    # 部件
    create_table :units do |t|
      t.references :unit_category, index: true, default: 1
      t.references :order, index: true
      t.string :name, null: false, index: true, default: '', uniq: true # 编码
      t.string :full_name #部件名称
      t.references :material # 板料
      t.integer :ply, default: 1 # 厚度
      t.integer :texture #纹理
      t.integer :color # 颜色
      t.integer :length, null:false, default: 1 # 长
      t.integer :width, null:false, default: 1 # 宽
      t.decimal :number, null:false, precision: 8, scale: 2, default: 0 #数量
      t.string :uom # 单位
      t.decimal :price, precision: 8, scale: 2, default: 0 # 单价
      t.string  :size, default: '' #剪裁尺寸
      t.string :note # 备注
      t.references :supply # 供应商
      t.boolean :is_custom, default: false # 是否为自定义报价的部件
      t.boolean :is_printed, default: false # 是否已打印
      
      t.string :edge #封边
      t.string :customer #终端信息
      t.integer :out_edge_thick, null:false, default: 0 # 看面封边厚
      t.integer :in_edge_thick, null:false, default: 0 # 里面封边厚
      t.string :back_texture # 背板材质
      t.string :door_type # 门板类别
      t.string :door_mould # 门板造型
      t.string :door_handle_type # 门板拉手类别
      t.string :door_edge_type # 门板封边类别
      t.integer :door_edge_thick # 门板封边厚
      # t.references :task, index: true, foreign_key: true
      t.integer :state, default: 0 #已创建生产任务，未创建生产任务
      t.string :craft # 工艺员
      t.boolean :deleted, default: false # 标记删除
      t.timestamps null: false
    end
  end
end
