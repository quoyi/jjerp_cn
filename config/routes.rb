Rails.application.routes.draw do
  resources :craft_categories do
    collection do
      post :find
    end
  end
  resources :uoms
  resources :sent_lists
  resources :banks
  resources :sents do
    collection do
      get :change # 修改发货信息
      get :replenish # 补充发货信息
      get :download # 下载发货信息
    end
  end
  resources :users, only: [:index, :edit, :update]

  resources :offers
  resources :expends
  resources :incomes do
    collection do
      get :stat # 财务统计
    end
  end
  resources :crafts
  resources :tasks
  resources :units
  resources :supplies
  resources :agents
  resources :unit_categories
  resources :user_categories
  resources :order_categories
  resources :part_categories do
    collection do
      post :find
    end
  end
  resources :material_categories
  resources :products
  resources :parts
  resources :materials do
    collection do
      post :find # 查找指定板料
    end
  end
  resources :indents do
    collection do
      get :incomes # 到款详细
      get :generate # 生成报价单
      get :export_offer # 导出报价单
      get :export_parts # 导出配件清单
      get :preview # 预览配件清单
    end
  end
  resources :orders do
    collection do
      post :import # 导入拆单数据
      get :not_sent # 未发货
      get :producing # 生产中
      get :export # 导出
      get :unpack # 未打包
      get :packaged # 已打包
    end
    member  do
      get :custom_offer # 自定义报价
      get :package # 打包
      post :package # 打包
      get :reprint # 重新打印标签
      post :reprint # 重新打印标签
    end
  end
  resources :departments
  resources :permissions
  resources :roles
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations',
    unlocks: 'users/unlocks'
  }
  get 'statics/home'

  root 'statics#index'

  mount ChinaCity::Engine => '/china_city'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     #   end
end
