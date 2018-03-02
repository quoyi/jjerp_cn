# config valid only for current version of Capistrano
# lock '3.6.1'

set :application, 'jjerp.cn'
set :repo_url, 'git@gitlab.com:beitaz/jjerp.cn.git'
set :deploy_user, 'bestar'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/ruby/jjerp.cn'

# Default value for :scm is :git
# set :scm, :git

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

set :rvm_ruby_version, '2.3.6'
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

# If you want to restart using `touch tmp/restart.txt`, add this to your config/deploy.rb:
#   set :passenger_restart_with_touch, true
# If you want to restart using `passenger-config restart-app`, add this to your config/deploy.rb:
#   set :passenger_restart_with_touch, false # Note that `nil` is NOT the same as `false` here
# If you don't set `:passenger_restart_with_touch`, capistrano-passenger will check what version of passenger you are running
# and use `passenger-config restart-app` if it is available in that version.

namespace :deploy do
  # desc "create test.rb file"
  # file 'test.rb' do |f|
  # 	sh "touch #{f.name}"
  # end

  desc "Update Sentry's configuration in file: config/application.rb"
  task :update_sentry_config do
    on roles(:app) do
      # execute "ls -l"
      # info "Update Sentry's configuration in file: config/application.rb"
      # execute "cd #{current_path}/config/ && cat application.rb"

      # 查找并替换 不包含符号# 开头的 config.dsn 字符串 为 #config.dsn
      # execute "sed -i 's/[^#]config.dsn/#config.dsn/g' #{current_path}/config/application.rb"

      execute "mkdir #{current_path}/public/excels/expends && chmod 666 #{current_path}/public/excels/expends"
      execute "mkdir #{current_path}/public/excels/incomes && chmod 666 #{current_path}/public/excels/incomes"
      execute "mkdir #{current_path}/public/excels/offers && chmod 666 #{current_path}/public/excels/offers"
      execute "mkdir #{current_path}/public/excels/orders && chmod 666 #{current_path}/public/excels/orders"
      execute "mkdir #{current_path}/public/excels/parts && chmod 666 #{current_path}/public/excels/parts"
      execute "mkdir #{current_path}/public/excels/sent_lists && chmod 666 #{current_path}/public/excels/sent_lists"
      execute "mkdir #{current_path}/public/images && chmod 666 #{current_path}/public/images"
      info '自动部署完成！'
    end
  end
end

after :deploy, 'deploy:update_sentry_config'
