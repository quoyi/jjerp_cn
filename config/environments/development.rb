Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false
  # 不输出静态资源日志
  # config.assets.logger = false
  config.encoding = 'utf-8'

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # 配置 权限验证，生产环境下，需要修改 host 为实际域名
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  # 邮件服务器配置
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV['EMAIL_ADDRESS'],
    port: ENV['EMAIL_PORT'],
    domain: ENV['EMAIL_DOMAIN'],
    authentication: ENV['EMAIL_AUTH'],
    user_name: ENV['EMAIL_USERNAME'],
    password: ENV['EMAIL_PASSWORD']
  }
end
