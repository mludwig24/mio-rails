module ApplicationHelper
end

# Re-opening the Bootstrap Form to customize.
module BootstrapForm
	module Helpers
		module Bootstrap
			## Allows to not have the <p> tag inside the form control.
			def static_control_div(name, options = {}, &block)
				## Mostly copy/paste from the original static_control:
				##   https://github.com/bootstrap-ruby/rails-bootstrap-forms/blob/master/lib/bootstrap_form/helpers/bootstrap.rb
				html = if block_given?
					capture(&block)
				else
					object.send(name)
				end
				form_group_builder(name, options) do
					content_tag(:div, html)
				end
			end
		end
	end
end