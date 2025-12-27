source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.2'
# Use postgresql as the database for Active Record
gem "pg" # , "~> 1.1"
#
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
gem 'active_model_serializers'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false # , '>= 1.1.0'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

# Transfert access tokens JsonWebToken encoded
gem 'jwt'

# Depricated gems
# ruby 3.5
gem 'ostruct'

# Even production DB will be seeded with faked data
gem 'faker'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :windows]

  # Testing with RSpec
  gem 'rspec-rails'
  gem 'rspec-json_matchers'
  gem 'factory_bot_rails'
  gem 'database_cleaner'

  # Better console
  gem 'pry-rails'
  gem 'pry-rescue'
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:windows, :jruby]
