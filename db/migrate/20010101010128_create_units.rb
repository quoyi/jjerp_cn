class CreateUnits < ActiveRecord::Migration
  def change
    # 部件
    create_table :units do |t|
      t.references :unit_category, index: true
      t.references :order, index: true, foreign_key: true
      t.string :serial, null: false, index: true, uniq: true # 编码
      t.string :unit_name #部件名称
      t.references :material, null: false # 板料名称
      t.integer :ply # 厚度
      t.integer :texture #纹理
      t.integer :color # 颜色
      t.integer :length # 长
      t.integer :width # 宽
      t.integer :number #数量
      t.string  :size #剪裁尺寸
      t.string :note # 备注
      t.string :edge #封边
      t.string :customer #终端信息
      t.integer :out_edge_thick # 看面封边厚
      t.integer :in_edge_thick # 里面封边厚
      t.string :back_texture # 背板材质
      t.string :door_type # 门板类别
      t.string :door_mould # 门板造型
      t.string :door_handle_type # 门板拉手类别
      t.string :door_edge_type # 门板封边类别
      t.integer :door_edge_thick # 门板封边厚
      t.references :task, index: true, foreign_key: true
      t.integer :state, default: 0 #已创建生产任务，未创建生产任务
      t.string :craft # 工艺员
      t.timestamps null: false
    end
  end
end
