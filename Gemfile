source 'https://rubygems.org'
# source 'https://gems.ruby-china.com'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

ruby '2.6.6'

gem 'rails', '6.1.0.rc1'
gem 'rails-i18n'
# gem 'mysql2', '~> 0.5'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'redis', '~> 4.0'
gem 'hiredis'
gem 'image_processing', '~> 1.2'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'devise'
gem 'cancancan'
# gem 'rolify'

gem 'kaminari'
gem 'simple_form'
gem 'nested_form'
gem 'rucaptcha'
gem 'recaptcha'
gem 'social-share-button'
gem 'ancestry'
gem 'enumize'
gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'by_star', git: 'git://github.com/radar/by_star'
gem 'bulk_insert', github: 'huacnlee/bulk_insert', branch: 'fix-for-rails-6.1'
gem 'figaro'
gem 'lograge'
# gem 'activestorage-aliyun'
gem 'rack-attack'
gem 'sentry-raven'
# gem 'newrelic_rpm' # 性能监控(performance monitoring)
# gem 'rails_workflow' # 工作流（已无法使用，需要修改）
# 读写excel
gem 'writeexcel', '~> 1.0', '>= 1.0.5'
# 字符转换（解决乱码）
# gem 'iconv', '~> 1.0', '>= 1.0.4'

# 定时任务，用于定时清理 public/excels/ 目录
gem 'whenever', '~> 0.9.7'
gem 'barby', '~> 0.6.4' # 条形码
gem 'chunky_png'
gem 'qiniu', '~> 6.8.1'

# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc

# Use Unicorn as the app server
# gem 'unicorn'

# 打印
gem 'prawn'
gem 'prawn-print'
gem 'prawn-table'
gem 'prawnto_2', require: 'prawnto'

gem 'china_city'

group :development, :test do
  gem 'bullet', github: 'flyerhzm/bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry'
  gem 'pry-byebug'
end

group :development do
  gem 'annotate'
  gem 'rubocop'
  gem 'overcommit'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano', '~> 3.6'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rails-db'
  gem 'capistrano-rvm'
  gem 'listen', '~> 3.2'
  gem 'squasher'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 4.0.3'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'database_cleaner-redis'
  gem 'rails-controller-testing'
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
