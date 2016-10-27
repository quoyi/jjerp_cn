#! /usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
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

# Fetch and parse HTML document
doc = Nokogiri::HTML(open('http://www.stats.gov.cn/tjsj/tjbz/xzqhdm/201608/t20160809_1386477.html'))

puts "### 查找省市县"
i = 1
doc.search('div.center div.center_xilan div.xilan_con p.MsoNormal').each do |p|
  pro = Provinces.new
  # pro.id = i
  pro.area_code = p.search("span[lang='EN-US']").text.gsub("　","")
  pro.name = p.search("span[style='font-family: 宋体']").text.gsub("　","")
  pro.save
  i += 1
  puts "已爬：" + i.to_s
end
puts "############### 查找完成！###############"


# puts "### Search for nodes by css"
# doc.css('nav ul.menu li a', 'article h2').each do |link|
#   puts link.content
# end

# puts "### Search for nodes by xpath"
# doc.xpath('//nav//ul//li/a', '//article//h2').each do |link|
#   puts link.content
# end