####################################### 代理商 #######################################
Agent.create(id: 1,name: 'DL0001', province: 17, full_name: '小秦代理', contacts: '王xx', mobile: '18610086121', logistics: '顺丰')
Agent.create(id: 2,name: 'DL0002', province: 17, full_name: '傣家代理', contacts: '岳xx', mobile: '18610086122', logistics: '圆通')
Agent.create(id: 3,name: 'DL0003', province: 17, full_name: '小孙代理', contacts: '孙x', mobile: '18610086123', logistics: '韵达')
puts 'created Agent success ! '

####################################### 供应商 #######################################
Supply.create(id: 1,name: 'GY0001', full_name: '小胡供应', mobile: '15215211521', bank_account: '627001702381000001', note: '优质代理商')
Supply.create(id: 2,name: 'GY0002', full_name: '小李供应', mobile: '18618611861', bank_account: '627402709342020582', note: '一级代理商')
Supply.create(id: 3,name: 'GY0003', full_name: '小杨供应', mobile: '18318311831', bank_account: '600807920384014023', note: '普通代理商')
puts 'created Supplier success ! '

####################################### 配件种类 #######################################
PartCategory.create(id: 4, parent_id: 1, name: '100侧拉篮', buy: 100.00, uom: '个', price: 110.00, store: 100, brand: '耐用牌', supply_id: 1)
PartCategory.create(id: 5, parent_id: 1, name: '200侧拉篮', buy: 200.00, uom: '个', price: 210.00, store: 50, brand: '坚固牌', supply_id: 1)
PartCategory.create(id: 6, parent_id: 1, name: '400侧拉篮', buy: 300.00, uom: '个', price: 310.00, store: 10, brand: '无敌牌', supply_id: 3)
PartCategory.create(id: 7, parent_id: 2, name: '铜质滑轨', buy: 100.00, uom: '个', price: 110.00, store: 50, brand: '耐用牌', supply_id: 1)
PartCategory.create(id: 8, parent_id: 2, name: '铁质滑轨', buy: 200.00, uom: '个', price: 210.00, store: 50, brand: '坚固牌', supply_id: 2)
PartCategory.create(id: 9, parent_id: 2, name: '钢质滑轨', buy: 300.00, uom: '个', price: 310.00, store: 10, brand: '无敌牌', supply_id: 3)
PartCategory.create(id: 10, parent_id: 3, name: '普通角线', buy: 100.00, uom: '米', price: 110.00, store: 100, brand: '耐用牌', supply_id: 1)
PartCategory.create(id: 11, parent_id: 3, name: '高级角线', buy: 200.00, uom: '米', price: 210.00, store: 50, brand: '坚固牌', supply_id: 2)
PartCategory.create(id: 12, parent_id: 3, name: '特制角线', buy: 500.00, uom: '米', price: 510.00, store: 10, brand: '无敌牌', supply_id: 3)
puts 'created PartCategory success ! '

####################################### 板料种类 #######################################
MaterialCategory.create(id: 1, oftype: 0, name:'3mm')
MaterialCategory.create(id: 2, oftype: 0, name:'5mm')
MaterialCategory.create(id: 3, oftype: 0, name:'15mm')
MaterialCategory.create(id: 4, oftype: 0, name:'16mm')
MaterialCategory.create(id: 5, oftype: 0, name:'17mm')
MaterialCategory.create(id: 6, oftype: 0, name:'18mm')
MaterialCategory.create(id: 7, oftype: 0, name:'25mm')
MaterialCategory.create(id: 8, oftype: 0, name:'36mm')
MaterialCategory.create(id: 9, oftype: 1, name:'颗粒板')
MaterialCategory.create(id: 10, oftype: 1, name:'密度板')
MaterialCategory.create(id: 11, oftype: 1, name:'多层板')
MaterialCategory.create(id: 12, oftype: 1, name:'生态板')
MaterialCategory.create(id: 13, oftype: 1, name:'实木板')
MaterialCategory.create(id: 14, oftype: 2, name:'国色天香')
MaterialCategory.create(id: 15, oftype: 2, name:'一帘幽梦')
puts 'created MaterialCategory success ! '

####################################### 板料 #######################################
Material.create(id: 1, ply: 1, texture: 11, color: 14, store: 50, buy: 100.00, price: 110.00, name: '39fd6a', full_name: '国色天香多层板3mm', uom: '平方', supply_id: 1);
Material.create(id: 2, ply: 1, texture: 11, color: 15, store: 50, buy: 100.00, price: 120.00, name: '39fd6b', full_name: '一帘幽梦多层板3mm', uom: '平方', supply_id: 1);
Material.create(id: 3, ply: 2, texture: 11, color: 14, store: 50, buy: 100.00, price: 130.00, name: '39fd6c', full_name: '国色天香多层板5mm', uom: '平方', supply_id: 1);
Material.create(id: 4, ply: 2, texture: 11, color: 15, store: 50, buy: 100.00, price: 140.00, name: '39fd6d', full_name: '一帘幽梦多层板5mm', uom: '平方', supply_id: 1);
Material.create(id: 5, ply: 1, texture: 9, color: 14, store: 50, buy: 100.00, price: 150.00, name: '39fd6e', full_name: '国色天香颗粒板3mm', uom: '平方', supply_id: 1);
Material.create(id: 6, ply: 1, texture: 9, color: 15, store: 50, buy: 100.00, price: 160.00, name: '39fd6f', full_name: '一帘幽梦颗粒板3mm', uom: '平方', supply_id: 1);
Material.create(id: 7, ply: 2, texture: 9, color: 14, store: 50, buy: 100.00, price: 170.00, name: '39fd6g', full_name: '国色天香颗粒板5mm', uom: '平方', supply_id: 1);
Material.create(id: 8, ply: 2, texture: 9, color: 15, store: 50, buy: 100.00, price: 180.00, name: '39fd6h', full_name: '一帘幽梦颗粒板5mm', uom: '平方', supply_id: 1);
Material.create(id: 9, ply: 3, texture: 11, color: 14, store: 50, buy: 100.00, price: 190.00, name: '39fd6i', full_name: '国色天香多层板15mm', uom: '平方', supply_id: 1);
Material.create(id: 10, ply: 3, texture: 11, color: 15, store: 50, buy: 100.00, price: 200.00, name: '39fd6j', full_name: '一帘幽梦多层板15mm', uom: '平方', supply_id: 1);
Material.create(id: 11, ply: 4, texture: 11, color: 14, store: 50, buy: 100.00, price: 210.00, name: '39fd6k', full_name: '国色天香多层板16mm', uom: '平方', supply_id: 1);
Material.create(id: 12, ply: 4, texture: 11, color: 15, store: 50, buy: 100.00, price: 220.00, name: '39fd6l', full_name: '一帘幽梦多层板16mm', uom: '平方', supply_id: 1);
Material.create(id: 13, ply: 3, texture: 9, color: 14, store: 50, buy: 100.00, price: 230.00, name: '39fd6m', full_name: '国色天香颗粒板15mm', uom: '平方', supply_id: 1);
Material.create(id: 14, ply: 3, texture: 9, color: 15, store: 50, buy: 100.00, price: 240.00, name: '39fd6n', full_name: '一帘幽梦颗粒板15mm', uom: '平方', supply_id: 1);
Material.create(id: 15, ply: 4, texture: 9, color: 14, store: 50, buy: 100.00, price: 250.00, name: '39fd6o', full_name: '国色天香颗粒板16mm', uom: '平方', supply_id: 1);
Material.create(id: 16, ply: 4, texture: 9, color: 15, store: 50, buy: 100.00, price: 260.00, name: '39fd6p', full_name: '一帘幽梦颗粒板16mm', uom: '平方', supply_id: 1);
Material.create(id: 17, ply: 6, texture: 9, color: 14, store: 50, buy: 100.00, price: 270.00, name: '39fd6q', full_name: '国色天香颗粒板18mm', uom: '平方', supply_id: 1);
Material.create(id: 18, ply: 6, texture: 9, color: 15, store: 50, buy: 100.00, price: 280.00, name: '39fd6r', full_name: '一帘幽梦颗粒板18mm', uom: '平方', supply_id: 1);
Material.create(id: 19, ply: 6, texture: 10, color: 14, store: 50, buy: 100.00, price: 290.00, name: '39fd6s', full_name: '国色天香密度板18mm', uom: '平方', supply_id: 1);
puts 'created Material success ! '


####################################### 银行卡 #######################################
Bank.create(name: '张三', bank_name: '中国银行', bank_card: '627001702381000001', balance: 0, is_default: 1)
Bank.create(name: '李四', bank_name: '工商银行', bank_card: '627001702381000002', balance: 0)
Bank.create(name: '王五', bank_name: '招商银行', bank_card: '627001702381000003', balance: 0)
Bank.create(name: '刘六', bank_name: '建设银行', bank_card: '627001702381000004', balance: 0)
puts 'created Bank success ! '

######################################## 工艺 #######################################
CraftCategory.create(full_name: '异形', uom: '次', price: 100)
CraftCategory.create(full_name: '桌面', uom: '平方', price: 400)
CraftCategory.create(full_name: '酒架', uom: '个', price: 120)
CraftCategory.create(full_name: '格子抽', uom: '个', price: 50)
CraftCategory.create(full_name: '哑光G型拉手', uom: '个', price: 18)
CraftCategory.create(full_name: '高光G型拉手', uom: '个', price: 32)
CraftCategory.create(full_name: '免拉手工艺', uom: '个', price: 10)
CraftCategory.create(full_name: '其他', uom: '个', price: 70)
CraftCategory.create(full_name: '常规工艺', uom: '次', price: 8)