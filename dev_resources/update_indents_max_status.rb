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

class Indents < LocalTables
end
class Orders < LocalTables
end

Indents.transaction do
  Indents.all.each do |indent|
    indent.update!(max_status: Orders.where(indent_id: indent.id).pluck(:status).max)
  end
end

