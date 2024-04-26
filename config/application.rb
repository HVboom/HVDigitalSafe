require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HVDigitalSafe
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = 'Central Time (US & Canada)'
    # config.eager_load_paths << Rails.root.join('extras')

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Single DB connection
    ### config.active_record.legacy_connection_handling = false

    # Allow access from and to all application specific domains
    # see https://guides.rubyonrails.org/configuring.html#actiondispatch-hostauthorization
    #   production:  hvdigitalsafe.hvboom.org
    #   development: hvdigitalsafe.demo.hvboom.org
    config.hosts = [ %r{hvdigitalsafe\.([^\.]+\.)?hvboom\.org} ]
  end
end
