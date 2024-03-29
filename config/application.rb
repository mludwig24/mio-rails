require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MioRails
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Arizona'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.load_path += 
        Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = "en-US"
    config.i18n.available_locales = ["es-MX", "en-US"]
    config.assets.initialize_on_precompile = true

    ActiveRecord::SessionStore::Session.table_name = 'mio_js_sessions'

    ## Load up the MIO settings.
    begin
        ENV.update YAML.load_file('config/mio.yml')[Rails.env]
    rescue => e
        logger.fatal "Failed to load MIO YAML file:  #{e.message}"
    end
  end
end
