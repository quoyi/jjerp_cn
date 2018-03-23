# source 'https://rubygems.org'
source 'https://gems.ruby-china.org'

# 指定ruby版本
ruby "2.4.1"

# 权限认证
gem 'devise'
# gem 'cancancan'
# gem 'rolify'
# gem 'by_star', git: 'git://github.com/radar/by_star'
# 前端样式 Bootstrap
gem 'bootstrap-sass'
# 使用第三方图标库
gem 'font-awesome-sass', '~> 4.2.0'
# 日期选择插件
gem 'bootstrap-datepicker-rails', '~> 1.6', '>= 1.6.0.1'
# 嵌套表单
gem 'nested_form'
# 增强型下拉选择框(基于jquery的增强型选择框)
gem 'select2-rails', '~> 4.0.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.10'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.13', '< 0.5'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# 读写excel
gem 'writeexcel', '~> 1.0', '>= 1.0.5'
# 字符转换（解决乱码）
# gem 'iconv', '~> 1.0', '>= 1.0.4'

# 定时任务，用于定时清理 public/excels/ 目录
gem 'whenever', '~> 0.9.7'
# 条形码
gem 'barby', '~> 0.6.4'
gem 'chunky_png'
# 性能监控(performance monitoring)
gem 'newrelic_rpm'

gem 'qiniu', '~> 6.8.1'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# 这里不指定小于 5.0.0 时会导致左边菜单无法切换
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'jquery-turbolinks'
gem 'turbolinks', '~> 2.5.3', '< 5.0.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

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

# 全局变量
gem 'figaro'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'annotate'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'overcommit'
  gem 'pry'
  gem 'rubocop'
end

group :development do
  gem 'capistrano', '~> 3.6'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
