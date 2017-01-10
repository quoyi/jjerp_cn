# config valid only for current version of Capistrano
# lock '3.6.1'

set :application, 'jjerp.cn'
set :repo_url, 'https://github.com/bestar-zhao/jjerp.cn.git'
set :deploy_user, 'bestar'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/#{fetch(:deploy_user)}/jjerp.cn"

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

set :rvm_ruby_version, '2.3.0'
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

# If you want to restart using `touch tmp/restart.txt`, add this to your config/deploy.rb:
#   set :passenger_restart_with_touch, true
# If you want to restart using `passenger-config restart-app`, add this to your config/deploy.rb:
#   set :passenger_restart_with_touch, false # Note that `nil` is NOT the same as `false` here
# If you don't set `:passenger_restart_with_touch`, capistrano-passenger will check what version of passenger you are running
# and use `passenger-config restart-app` if it is available in that version.

namespace :deploy do
  desc "Update Sentry's configuration in file: config/application.rb"
  task :update_sentry_config do
    execute "ls -l"
    info "Update Sentry's configuration in file: config/application.rb"
    execute "cd config/ && cat application.rb"
  end
end

after :deploy, "deploy:update_sentry_config"
