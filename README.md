# 初始化 jjerp.cn 代码仓库

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
```
