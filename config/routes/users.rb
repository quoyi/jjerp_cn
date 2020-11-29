# 参考文档: https://www.rubydoc.info/github/heartcombo/devise/master/ActionDispatch/Routing/Mapper%3Adevise_for
devise_for :users, path: '',
                   #  controllers: {
                   #    sessions: 'users/sessions',
                   #    registrations: 'users/registrations'
                   #  },
                   path_names: {
                     sign_in: 'login',
                     sign_out: 'logout',
                     password: 'secret',
                     confirmation: 'verify',
                     unlock: 'unlock',
                     sign_up: 'register'
                   }

# 必须在 devise 之下
resources :users, only: %i[index show edit update] do
  get :profile
end
