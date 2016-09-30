Role.register_permission class: 'RolesController',
  name: '角色权限',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'UsersController',
  name: '用户',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'AgentsController',
  name: '代理商',
  actions: {
    '新建' => [:new, :create],
    '列表' => [:index, :search],
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show, :search]
}
Role.register_permission class: 'SuppliesController',
  name: '供应商',
  actions: {
    '新建' => [:new, :create],
    '列表' => [:index],
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'OrderCategoriesController',
  name: '订单类型',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'UnitsController',
  name: '部件',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'PartCategoriesController',
  name: '配件类型',
  actions: {
    '新建' => [:new, :create],
    '列表' => [:index, :find],
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show, :find]
}

Role.register_permission class: 'PartsController',
  name: '配件',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'MaterialCategoriesController',
  name: '板料类型',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'MaterialsController',
  name: '板料',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'IndentsController',
  name: '订单',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '生成报价' => [:generate],
    '详细' => [:show],
    '包装打印' => [:unpack, :package]
}
Role.register_permission class: 'OrdersController',
  name: '子订单',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show],
    '生产任务' => [:producing],
    '未发货' => [:not_sent]
}

Role.register_permission class: 'IncomesController',
  name: '收入',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show],
    '收支统计' => [:stat]
}

Role.register_permission class: 'ExpendsController',
  name: '支出',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
Role.register_permission class: 'SentsController',
  name: '发货',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show],
    '添加发货信息' => [:change],
    '下载发货清单' => :download,
    '回填物流单号' => :replenish
}

Role.register_permission class: 'SentListsController',
  name: '发货清单',
  actions: {
    '新建' => [:new, :create],
    '列表' => :index,
    '修改' => [:edit, :update],
    '删除' => [:destroy],
    '详细' => [:show]
}
