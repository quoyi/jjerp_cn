# 初始化 jjerp.cn 代码仓库

## TODOList

- [ ] 授权过期检查方式
- [ ] 重构 `db/init/area.rb` 数据 [县以上行政区划代码](http://www.mca.gov.cn/article/sj/xzqh/2020/2020/2020112010001.html)

## 项目笔记

```shell
$ rake db:drop db:create db:migrate db:seed
...
```

## 配置邮件

修改 `config/initializers/devise.rb` 中的 `config.mailer_sender` 等配置

```shell
config.action_mailer.raise_delivery_errors = true # 开发环境中设为 true， 生产环境需要设置为 false
config.action_mailer.default charset: 'utf-8'
# Devise 配置
# config.action_mailer.default_url_options[:host] = 'yoursite.herokuapp.com' # 生产环境 production.rb 中使用
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
config.mailer_sender = 'jjerp_cn@qq.com' # 此配置会覆盖 mailer 中的 from_to 属性，若未设置正确则报错找不到 from_to
config.mailer = 'Devise::Mailer'
```

修改 `config/environments/development.rb` 配置邮箱

```shell
# 邮件服务器配置
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp.qq.com',
  port: 25,
  domain: 'qq.com'
  authentication: 'login',
  user_name: ENV['email_username'], # 此处为邮箱账号
  password: ENV['email_password'] # 此处的密码并非 QQ 登录密码，而是启用 SMTP 时生成的秘钥。
}
```

## 批量修改 migration 文件

```sh
grep -rl "ActiveRecord::Migration$" db | xargs sed -i "" "s/ActiveRecord::Migration/ActiveRecord::Migration[6.0]/g"
squasher -m 6.0 -r 202012
```

## 移除 Sprockets

- 从 `Gemfile` 中移除 `sass-rails`
- 修改 `config/application.rb` 引用

  ```ruby
  # require 'rails/all'
  require "rails"
  # Pick the frameworks you want:
  require "active_model/railtie"
  require "active_job/railtie"
  require "active_record/railtie"
  require "active_storage/engine"
  require "action_controller/railtie"
  require "action_mailer/railtie"
  require "action_mailbox/engine"
  require "action_text/engine"
  require "action_view/railtie"
  require "action_cable/engine"
  # require "sprockets/railtie"
  require "rails/test_unit/railtie"
  ```

- 从 `config/environments/development.rb` 中移除

  ```ruby
  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets
  config.assets.debug = true

  # Suppress logger output for asset requests
  config.assets.quiet = true
  ```

- 从 `config/environments/production.rb` 中移除

  ```ruby
  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false
  ```

- 移除 `config/initializers/assets.rb` 文件
- ~~删除 `app/assets` 目录~~（建议保留作为回退备份）

## 文档

- [可用断言](https://guides.rubyonrails.org/testing.html#available-assertions)
- [并行测试](https://guides.rubyonrails.org/testing.html#parallel-testing-with-processes)
