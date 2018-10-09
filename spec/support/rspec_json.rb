require 'rspec-json_matchers'
RSpec.configure do |config|
  config.include RSpec::JsonMatchers::Matchers, type: :request
end
