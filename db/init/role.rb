PartCategory.create(id: 1, parent_id: 0, name:'拉篮')
PartCategory.create(id: 2, parent_id: 0, name:'滑轨')
PartCategory.create(id: 3, parent_id: 0, name:'角线')

OrderCategory.create(:name => "橱柜")
OrderCategory.create(:name => "衣柜")
OrderCategory.create(:name => "门")
OrderCategory.create(:name => "配件")
OrderCategory.create(:name => "其他")

UnitCategory.create(:name => "板料")
UnitCategory.create(:name => "配件")
UnitCategory.create(:name => "工艺")

Uom.create(name: '平方')
Uom.create(name: '个')
Uom.create(name: '次')
Uom.create(name: '米')

UserCategory.create(id: 1, serial: 'UC0001', name: '普通用户', nick: 'normal', visible: true)
UserCategory.create(id: 2, serial: 'UC0002', name: '企业用户', nick: 'employe', visible: true)
UserCategory.create(id: 3, serial: 'UC0003', name: '代理商', nick: 'agent', visible: true)
UserCategory.create(id: 4, serial: 'UC0004', name: '供应商', nick: 'supply', visible: true)
UserCategory.create(id: 5, serial: 'UC0005', name: '管理员', nick: 'admin', visible: true)
UserCategory.create(id: 6, serial: 'UC0006', name: '超级管理员', nick: 'super', visible: false)
puts 'created UserCategory success ! '
####################################### 角色 #######################################
Role.find_or_create_by!(name: '超级管理员', nick: 'super_admin')
permissions = Role.permissions
#管理员角色 操作所有
admin = Role.find_or_create_by!(name: '管理员', nick: 'admin')
permissions.each_pair do |k, v|
  admin.role_permissions.create(klass: k, actions: v[:actions].values.flatten.map(&:to_s).join(','))
end

normal = Role.find_or_create_by!(name: '普通用户', nick: 'normal')
permissions.each_pair do |k, v|
  normal.role_permissions.create(klass: k, actions: 'show,edit,update') if k == 'UsersController'
end

#财务角色 增删改查 财务数据;查看 订单数据、物流发货、客户数据、供应商。
financial = Role.find_or_create_by!(name: '财务', nick: 'financial')
permissions.each_pair do |k, v|
  if ['IncomesController', 'ExpendsController'].include?(k)
    financial.role_permissions.create(klass: k, actions: v[:actions].values.flatten.map(&:to_s).join(','))
  end

  if ['IndentsController', 'OrdersController', 'AgentsController', 'SuppliesController'].include?(k)
    financial.role_permissions.create(klass: k, actions: 'index,show')
  end
end

#下单员角色: 增改查 客户、基础数据(板料、配件,含售价)、订单数据(订单、子订单、挂起单); 查看 生产任务(正在生产的订单)、物流发货
order = Role.find_or_create_by!(name: '下单员', nick: 'order')
permissions.each_pair do |k, v|
  if ['AgentsController', 'PartCategoriesController', 'MaterialCategoriesController', 'IndentsController'].include?(k)
    order.role_permissions.create(klass: k, actions: 'index,update,edit,show')
  end
  if ['SentsController'].include?(k)
    order.role_permissions.create(klass: k, actions: 'index,show')
  end
  if k == 'OrdersController'
    order.role_permissions.create(klass: k, actions: 'ndex,update,edit,show,producing')
  end
end

#工人角色: 查看 生产任务(打印包装标签)
employee = Role.find_or_create_by!(name: '工人', nick: 'employe')
permissions.each_pair do |k, v|
  if k == 'UsersController'
    employee.role_permissions.create(klass: k, actions: 'show,edit,update')
  end
  if k == 'IndentsController'
    employee.role_permissions.create(klass: k, actions: 'unpack,package')
  end
  if k == 'OrdersController'
    employee.role_permissions.create(klass: k, actions: 'producing,unpack,packaged')
  end
end

#厂长角色: 查看 基础数据、订单数据、生产任务、物流发货
manager = Role.find_or_create_by!(name: '厂长', nick: 'manager')
permissions.each_pair do |k, v|
  if k == 'IndentsController'
    manager.role_permissions.create(klass: k, actions: 'index,show,unpack,package')
  end
  if ['PartCategoriesController', 'MaterialCategoriesController', 'SentsController'].include?(k)
    manager.role_permissions.create(klass: k, actions: 'index,show')
  end
  if k == 'OrdersController'
    manager.role_permissions.create(klass: k, actions: 'index,show,producing')
  end
end

# 发货部角色:查看 生产任务、入库与否、订单信息、信用级别; 增删改查 发货安排
delivery = Role.find_or_create_by!(name: '发货部', nick: 'delivery')
permissions.each_pair do |k, v|
  if k == 'IndentsController'
    delivery.role_permissions.create(klass: k, actions: 'index,show,unpack,package')
  end
  if k == 'AgentsController'
    delivery.role_permissions.create(klass: k, actions: 'index,show')
  end
  
  if k == 'SentsController'
    delivery.role_permissions.create(klass: k, actions: 'index,show,edit,update,destroy')
  end

  if k == 'OrdersController'
    delivery.role_permissions.create(klass: k, actions: 'index,show,producing')
  end
end

user = User.find_or_create_by!(email: Rails.application.secrets.admin_email) do |user|
  user.name = Rails.application.secrets.admin_name
  user.password = Rails.application.secrets.admin_password
  user.password_confirmation = Rails.application.secrets.admin_password
  super_admin = Role.find_or_create_by!(nick: 'super_admin', name: '超级管理员')
  financial = Role.find_or_create_by!(nick: 'financial', name: '财务')
  user.add_role!(super_admin.nick)
  # user.add_role!(financial.nick)
end
puts 'created User success !'

