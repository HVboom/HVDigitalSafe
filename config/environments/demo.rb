require_relative 'production'

Rails.application.configure do
  # config settings specific to
  # the demo environment.

  # Log to STDOUT by default
  # config.logger = ActiveSupport::Logger.new(STDOUT)
  # Log to file
  config.logger = ActiveSupport::Logger.new("log/demo.log")
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "debug")
end
