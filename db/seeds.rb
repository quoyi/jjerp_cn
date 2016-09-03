# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
####################################### 用户种类 #######################################
#require "#{Rails.root}/db/init/arear"
require "#{Rails.root}/db/init/role"
require "#{Rails.root}/db/init/basic"



####################################### 权限 #######################################
# Permission.find_or_create_by!(name: '用户', klass: 'UsersController', actions: 'index,edit,update')
# Permission.find_or_create_by!(name: '角色', klass: 'RolesController', actions: 'index,edit,update,:destroy,:show')
# Permission.find_or_create_by!(name: '订单', klass: 'IndentCategoriesController', actions: 'index,edit,update,:destroy,:show')
# Permission.find_or_create_by!(name: '子订单类型', klass: 'OrderCategoriesController', actions: 'index,edit,update,:destroy,:show')
# Permission.find_or_create_by!(name: '子订单', klass: 'OrdersController', actions: 'index,edit,update,:destroy,:show')
# Permission.find_or_create_by!(name: '板料类型', klass: 'MaterialCategoriesController', actions: 'index,edit,update,:destroy,:show')
# Permission.find_or_create_by!(name: '板料', klass: 'MaterialsController', actions: 'index,edit,update,:destroy,:show')
# Permission.find_or_create_by!(name: '部件类型', klass: 'UnitCategoriesController', actions: 'index,edit,update,:destroy,:show')
# Permission.find_or_create_by!(name: '部件', klass: 'UnitsController', actions: 'index,edit,update,:destroy,:show')
# Permission.find_or_create_by!(name: '配件类型', klass: 'PartCategoriesController', actions: 'index,edit,update,:destroy,:show')
# Permission.find_or_create_by!(name: '配件', klass: 'PartsController', actions: 'index,edit,update,:destroy,:show')
# Permission.find_or_create_by!(name: '工艺', klass: 'CraftsController', actions: 'index,edit,update,:destroy,:show')
# Permission.find_or_create_by!(name: '收入', klass: 'IncomesController', actions: 'index,edit,update,:destroy,:show')
# Permission.find_or_create_by!(name: '支出', klass: 'ExpendsController', actions: 'index,edit,update,:destroy,:show')
# puts 'created Role success ! '

