require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Jjerp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.autoload_paths << Rails.root.join("lib")
    config.autoload_paths << Rails.root.join('app').join('pdfs')

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    I18n.config.enforce_available_locales = false
    config.i18n.available_locales = ["zh-CN"]
    config.i18n.default_locale = "zh-CN".to_sym
    config.before_configuration do
      I18n.locale = "zh-CN".to_sym
      I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '**', '*.{rb,yml}')]
      I18n.reload!
    end

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # 定制 rails generator scaffold
    config.generators do |g|
      g.orm :active_record
      g.template_engine :erb
      g.test_framework :test_unit, fixture: true
      g.stylesheets false # 禁止生成scss
    end

    Raven.configure do |config|
      # jjerp.cn
      config.dsn = 'https://f366746ab9c94929906c5d960a447bc5:918fa9992f5d41889e229fe51a6f1e67@sentry.io/128322'
      # 其他
      #config.dsn = 'https://022c5ad877dd486cb4bf12596be3fa06:f9c7d4a12c264fecbfcce7f6fbb6af4f@sentry.io/128020'
    end
  end
end
