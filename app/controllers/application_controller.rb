class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	before_action :set_locale
	before_filter :prepare_for_mobile

	private
	## Is this a mobile device?
	def mobile_device?
	  if session[:mobile_param]
	    session[:mobile_param] == "1"
	  else
	    request.user_agent =~ /Mobile|webOS/
	  end
	end
	helper_method :mobile_device?
	## Change the format if it is mobile.
	def prepare_for_mobile
	  session[:mobile_param] = params[:mobile] if params[:mobile]
	  prepend_view_path Rails.root + 'app' + 'views' + 'mobile' if mobile_device?
	  # request.format = :mobile if mobile_device?
	end
	def which_layout
	  mobile_device? ? 'mobile' : 'application'
	end
	layout :which_layout

	## Setup language.
	def set_locale ## Pull the locale from the URL.
		I18n.locale = params[:locale] || 
			http_accept_language.compatible_language_from(I18n.available_locales)
	end
	def default_url_options(options={}) ## Set the default Locale for each link.
		logger.debug "default_url_options is passed options: #{options.inspect}\n"
		{ locale: I18n.locale }
	end
end
