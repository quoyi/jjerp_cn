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

class Provinces < LocalTables
end
class Cities < LocalTables
end
class Districts < LocalTables
end

# 打开文件(r只读、r+读写、w只写、w+创建并读写)
file = File.new("#{Dir.pwd}/db/init/area.rb", 'w+')

Provinces.all.order(:index).each do |province|
  file.puts("####################################### #{province.name} #######################################")
  file.puts("Province.create(name: '#{province.name}')")
  Cities.where(province_id: province.id).order(:index).each do |city|
    file.puts("City.create(name: '#{city.name}', province_id: '#{city.province_id}')")
    Districts.where(city_id: city.id).order(:area_code).each do |district|
      file.puts("District.create(name: '#{district.name}', city_id: '#{district.city_id}')")
    end
  end
  file.puts("puts '#{province.name}初始化完成! '")
end


# file.puts("####################################### 市 #######################################")
# cities.order(:index).each do |city|
  
# file.puts("puts '城市初始化完成! '")

# file.puts("####################################### 区县 #######################################")
# districts.order(:area_code).each do |district|
  
# end
# file.puts("puts '区县初始化完成! '")

# 关闭文件
file.close