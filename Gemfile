source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.1'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
gem 'mysql' ## MySQL
gem 'pg' ## PostgreSQL.
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
group :development do
	gem 'unicorn'
end

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'rails-i18n', '~> 4.0.0'
## Gives javascript access to translations.
gem "i18n-js"
## Auto adds untranslated.
gem "i18n-tasks"
gem 'http_accept_language'
## Allows the dates to be input in the format the user expects.
gem 'delocalize', github: 'jackiig/delocalize', branch: '1-0-beta'
## Store the sessions in the DB.
gem 'activerecord-session_store', github: 'rails/activerecord-session_store'
## Used to make plain objects into xml and json.
gem 'activesupport', '~> 4.1.1'

gem 'angularjs-rails', '~> 1.2.16'
gem 'validates_timeliness', '~> 3.0'

gem 'haml'

gem "therubyracer"
gem "less-rails"
gem "twitter-bootstrap-rails",
	github: 'seyhunak/twitter-bootstrap-rails',
	branch: 'bootstrap3'
gem 'bootstrap_form'
gem 'nested_form' 
## Gives the ability to validate dates easily:
gem 'date_validator', '~> 0.7.0'
## Validate emails.
gem 'email_validator'
## Validate phones.
gem 'phony_rails'
group :development do
	gem 'guard-livereload', require: false
	gem 'guard-minitest', require: false
end
