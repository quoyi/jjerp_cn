source 'https://rubygems.org'
# source 'https://gems.ruby-china.com'
git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

ruby '2.6.6'

gem 'rails', '6.1.0.rc1'
gem 'mysql2', '~> 0.5'
gem 'puma', '~> 5.0'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.4', require: false
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

gem 'devise'
# gem 'cancancan'
# gem 'rolify'

# gem 'bootstrap-datepicker-rails', '~> 1.6', '>= 1.6.0.1'
# gem 'select2-rails', '~> 4.0.3'

gem 'simple_form'
gem 'nested_form'
gem 'figaro'
# gem 'by_star', git: 'git://github.com/radar/by_star'
gem 'sentry-raven'
gem 'newrelic_rpm' # 性能监控(performance monitoring)

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
# 分页
gem 'kaminari'

# 打印
gem 'prawn'
gem 'prawn-print'
gem 'prawn-table'
gem 'prawnto_2', require: 'prawnto'

gem 'china_city'

group :development, :test do
  gem 'annotate'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'overcommit'
  gem 'pry'
  gem 'rubocop'
end

group :development do
  gem 'capistrano', '~> 3.6'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rails-db'
  gem 'capistrano-rvm'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'web-console', '>= 4.0.3'
end
