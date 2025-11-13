source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.2.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5'
# Use Puma as the app server
gem 'puma', '~> 6.0'
# Use SCSS for stylesheets
gem 'sassc-rails'
# Modern JavaScript bundling with esbuild
gem 'jsbundling-rails'
# CSS bundling
gem 'cssbundling-rails'
# Hotwire's SPA-like page accelerator
gem 'turbo-rails'
# Hotwire's modest JavaScript framework
gem 'stimulus-rails'
# Build JSON APIs with ease
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Authentication
gem 'devise', '~> 4.9'

# Forms
gem 'simple_form'

# Authorization
gem 'pundit'

# HAML templating
gem 'haml-rails', '~> 2.1'

# Pagination
gem 'kaminari'

# CSV exports
gem 'csv', '~> 3.2'

# PDF generation
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

group :development, :test do
  # Debugging
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.8'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Background jobs
gem 'sidekiq', '~> 7.0'
gem 'sidekiq-scheduler', '~> 5.0'

# Email delivery
gem 'letter_opener', group: :development