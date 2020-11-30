Rails.application.routes.draw do
  # 发货计划
  resources :sent_lists do
    member do
      get :download
    end
  end

  # 发货
  resources :sents do
    # 修改发货信息、补充发货信息
    get :change, :replenish, on: :collection
  end

  # 收入
  resources :incomes do
    # 财务统计、订单扣款
    get :stat, :deduct, on: :collection
  end

  # 供应商、单位、任务、工艺
  resources :supplies, :units, :tasks, :crafts, :expends, :offers, :banks, :uoms, :templates

  # 子订单
  resources :orders do
    collection do
      # 查找指定 name（订单号）的子订单、、未发货、生产中、导出、未打包、打包、已打包
      get :find, :not_sent, :producing, :export, :unpack, :package, :packaged
      # 导入拆单数据、打包
      post :import, :package
    end
    member do
      # 自定义报价、重新打印标签、转款
      get :custom_offer, :reprint, :change_income
      # 打包、重新打印标签、转款
      post :pack, :reprint, :change_income
    end
  end

  # 总订单
  resources :indents do
    # 到款详细、生成报价单、导出报价单、导出配件清单、预览配件清单
    get :incomes, :generate, :export_offer, :export_parts, :preview, on: :collection
  end

  # 工艺类型
  resources :craft_categories do
    post :find, on: :collection
  end
  # 部件类型
  resources :part_categories do
    post :find, on: :collection
  end
  # 板材类型、订单类型、用户类型、单位类型
  resources :material_categories, :order_categories, :user_categories, :unit_categories

  # 板材
  resources :materials do
    post :find, on: :collection # 查找指定板料
  end

  # 代理商
  resources :agents do
    get :search, on: :collection
  end

  # 角色、权限、部门、部件、产品
  resources :roles, :permissions, :departments, :parts, :products

  authenticate :user, ->(u) { u.admin? } do
    # mount Sidekiq::Web, at: "sidekiq"
    mount PgHero::Engine, at: 'pghero'
    # mount ExceptionTrack::Engine, at: "exception-track"
  end

  draw :users

  get 'areas/find'

  controller :static do
    # 关于、联系、服务条款、隐私政策、授权过期、个人主页
    # get :about, :contact, :terms, :privacy, :expired, :home
    get :terms, :privacy, :expired
  end

  get :dashboard, to: 'users#dashboard'

  root 'static#index'

  # mount ChinaCity::Engine => '/china_city'
end
