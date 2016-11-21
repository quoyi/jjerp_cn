# 此脚本用于更新所有已存在的子订单属性：除背板外的板料数量 material_number = order.units.each{ |u| u.size * u.number unless u.is_backboard } 
require 'rubygems'
require 'active_record'

class LocalTables < ActiveRecord::Base
  self.abstract_class         = true  #共用连接池，减少数据库连接的消耗
  self.pluralize_table_names = false
end
LocalTables.establish_connection({
  adapter: 'mysql2',
  host:    'localhost',
  username: 'root',
  password: '123abc..',
  database: 'jjerp_dev'
})


class Orders < LocalTables
end
class MaterialCategories < LocalTables
end
class Units < LocalTables
  # 指定 ply 是否为背板
  def is_backboard?
    # 这里不能指定 self.where() 的原因： 实例对象调用此方法时会报错。
    mc = MaterialCategories.find_by_id(ply)
    if mc
      # "3mm".to_i = 3 （取第一个数字类型转换为整数） ; 小于 10mm 的板料为背板
      mc.name.to_i < 10
    else
      false
    end
  end
end

orders = Orders.all
orders.each do |order|
  number = 0
  Units.where(order_id: order.id).each do |unit|
    puts "订单：" + unit.name + " 的尺寸：" + unit.size.to_s + " 是否为背板：" + unit.is_backboard?.to_s
    # 不是背板，且填写了板料面积
    unless unit.is_backboard?
      if unit.size.blank?
        number += unit.number
      else
        number += unit.size.split(/[xX*×]/).map(&:to_i).inject(1){|result, item| result*=item}/(1000*1000).to_f * unit.number
      end
    end
  end
  order.update(material_number: number)
  # order.save!
end