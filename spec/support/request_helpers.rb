module Requests
  module JsonApiHelpers
    def json_response
      # @json_response ||= JSON.parse(response.body, symbolize_names: true)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end

RSpec.configure do |config|
  config.include Requests::JsonApiHelpers, type: :request
end
