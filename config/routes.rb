Rails.application.routes.draw do
  resources :banks
  resources :sents
  resources :users, only: [:index, :edit, :update]

  resources :offers
  resources :expends
  resources :incomes do
    collection do
      get :stat
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
  resources :part_categories
  resources :material_categories
  resources :products
  resources :parts
  resources :materials
  resources :orders do
    collection do
      post :import
      get :producing
      get :export
    end
  end
  resources :departments
  resources :indents do
    collection do
      get :generate
      get :not_sent
      get :export_offer
    end
    member do
      get :package
      post :package
    end
    collection do
      get :unpack
    end
    
  end
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
