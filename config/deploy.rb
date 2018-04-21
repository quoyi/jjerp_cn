# config valid only for current version of Capistrano
# lock '3.6.1'

set :application, 'jjerp.cn'
set :repo_url, 'git@github.com:beitaz/jjerp.cn.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/jjerp'

# Default value for :scm is :git
# set :scm, :git

# 设置远程仓库缓存，每次部署时使用 git pull 而不是 git clone
set :repository_cache, 'git_cache'
set :deploy_via, :remote_cache
set :git_shallow_clone, 1

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
# append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rvm_ruby_version, '2.4.1'
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle',
                                               'public/system', 'public/uploads', 'public/images', 'public/excels/expends',
                                               'public/excels/incomes', 'public/excels/offers', 'public/excels/orders',
                                               'public/excels/parts', 'public/excels/sent_lists')

# If you want to restart using `touch tmp/restart.txt`, add this to your config/deploy.rb:
#   set :passenger_restart_with_touch, true
# If you want to restart using `passenger-config restart-app`, add this to your config/deploy.rb:
#   set :passenger_restart_with_touch, false # Note that `nil` is NOT the same as `false` here
# If you don't set `:passenger_restart_with_touch`, capistrano-passenger will check what version of passenger you are running
# and use `passenger-config restart-app` if it is available in that version.

namespace :deploy do
  # desc "create test.rb file"
  # file 'test.rb' do |f|
  # sh "touch #{f.name}"
  # end
  desc 'check assets directory'
  task :check_directory do
    on roles(:all) do
      # execute "ls -l"
      # info "Update Sentry's configuration in file: config/application.rb"
      # execute "cd #{current_path}/config/ && cat application.rb"

      # 查找并替换 不包含符号# 开头的 config.dsn 字符串 为 #config.dsn
      # execute "sed -i 's/[^#]config.dsn/#config.dsn/g' #{current_path}/config/application.rb"

      # execute "mkdir -p #{deploy_to}/shared/public/excels/{expends,incomes,offers,orders,parts,sent_lists}"
      # execute "mkdir -p #{deploy_to}/shared/public/images"
      info 'Directory checked!'
    end
  end

  desc 'Create assets directory'
  task :create_directory do
    on roles(:all) do
      # execute "ls -l"
      # info "Update Sentry's configuration in file: config/application.rb"
      # execute "cd #{current_path}/config/ && cat application.rb"

      # 查找并替换 不包含符号# 开头的 config.dsn 字符串 为 #config.dsn
      # execute "sed -i 's/[^#]config.dsn/#config.dsn/g' #{current_path}/config/application.rb"

      # execute "mkdir -p #{deploy_to}/shared/public/excels/{expends,incomes,offers,orders,parts,sent_lists}"
      # execute "mkdir -p #{deploy_to}/shared/public/images"
      info 'Directory created!'
    end
  end
end

before :deploy, 'deploy:check_directory'
after :deploy, 'deploy:create_directory'
