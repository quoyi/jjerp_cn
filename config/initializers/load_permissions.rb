Role.register_permission class: 'RolesController',
  name: '角色权限',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'UsersController',
  name: '用户',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'AgentsController',
  name: '经销商',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'SuppliesController',
  name: '供应商',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'OrderCategoriesController',
  name: '订单类型',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'UnitsController',
  name: '部件',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'PartCategoriesController',
  name: '配件类型',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}

Role.register_permission class: 'PartsController',
  name: '配件',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'MaterialCategoriesController',
  name: '板料类型',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'MaterialsController',
  name: '板料',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'IndentsController',
  name: '订单',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '生成报价' => [:generate],
    '详细' => [:show],
    '包装打印' => [:unpack, :package]
}
Role.register_permission class: 'OrdersController',
  name: '子订单',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show],
    '生产任务' => [:producing]
}

Role.register_permission class: 'IncomesController',
  name: '收入',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show],
    '收支统计' => [:stat]
}

Role.register_permission class: 'ExpendsController',
  name: '支出',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'SentsController',
  name: '发货',
  actions: {
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
