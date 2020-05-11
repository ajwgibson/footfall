source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.4.6'

gem 'rails', '~> 5.2.4', '>= 5.2.4.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'

gem 'mini_racer', platforms: :ruby
gem 'bootsnap', '>= 1.1.0', require: false

gem 'active_model_serializers', '~> 0.10.0'

gem 'bootstrap', '~> 4.4.1'
gem 'bootstrap_form'
gem 'cancancan'
gem 'devise'
gem 'jquery-rails'
gem 'kaminari'
gem 'mini_magick'
gem 'paper_trail'
gem 'sweetalert-rails'
gem 'toastr-rails'
gem 'aws-sdk-rails', '~> 3'
gem 'aws-sdk-dynamodb', '~> 1.0.0'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
end

group :development do
  gem 'guard-rspec', require: false
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner'
  gem 'rubocop', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
