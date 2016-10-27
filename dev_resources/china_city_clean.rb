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
  database: 'chinacity'
})

class Area < LocalTables
end
class Provinces < LocalTables
end
class Cities < LocalTables
end
class Districts < LocalTables
end


areas = Area.all
# areas.each do |a|
#   # a.update(pid: a.area_code[0..1], cid:  a.area_code[2..3], did:  a.area_code[4..5])
#   puts "省份：" + a.area_code[0..1] + "    城市：" + a.area_code[2..3] + "    区县：" + a.area_code[4..5]
# end

areas.where(cid: '00', did: '00').each do |a|
  p = Provinces.new(name: a.name, area_code: a.area_code, index: a.area_code[0..1])
  p.save
end
puts "省份保存完毕！共" + Provinces.count.to_s + "条"

provinces = areas.where(cid: '00', did: '00')
areas.where(did: '00').where.not(cid: '00').each do |a|
  province_id = Provinces.find_by(index: a.area_code[0..1]).id
  city = Cities.new(province_id: province_id, name: a.name, area_code: a.area_code, index: a.area_code[2..3])
  city.save
end
puts "城市保存完毕！共" + Cities.count.to_s + "条"

areas.where.not(did: '00').where.not(cid: '00').each do |a|
  province_id = Provinces.find_by(index: a.area_code[0..1]).id
  city_id = Cities.find_by(province_id: province_id, index: a.area_code[2..3]).id
  district = Districts.new(city_id: city_id, name: a.name, area_code: a.area_code)
  district.save
end
puts "区县保存完毕！共" + Districts.count.to_s + "条"
puts "所有记录处理完毕！共" + Area.count.to_s + "条"

# array = [1,2,3,4,5,6,7,8,9,0]
# array.each do |a|
#   break if a == 3
#   puts "第一层循环打印：" + a.to_s
#   array.each do |aa|
#     break if aa == 3
#     puts "第二层循环打印：" + aa.to_s
#   end
# end