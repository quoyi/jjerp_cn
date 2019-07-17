Raven.configure do |config|
  config.dsn = "https://2aba1c44a946432a8193a91ff6679dd3:383b542a0d174ea2ab60acc501eea843@sentry.io/1503736"
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.processors -= [Raven::Processor::PostData] # Do this to send POST data
  # config.async = lambda { |event| SentryJob.perform_later(event) }
end
