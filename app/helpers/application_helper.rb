module ApplicationHelper
end

# Re-opening string to create phone numbers.
class String
	def raw_phone
		digits = self.split(//)

		if (digits.length == 11 and digits[0] == '1')
			# Strip leading 1
			digits.shift
		end
		digits.join()
	end
	def phone
		digits = self.raw_phone.split(//)

		if (digits.length == 11 and digits[0] == '1')
			# Strip leading 1
			digits.shift
		end

		if (digits.length == 10)
			return '%s-%s-%s' % [
				digits[0,3].join(),
				digits[3,3].join(),
				digits[6,4].join(),
			]
		end
		digits.join("")
	end
	def phone?
		self.raw_phone.match(/^(1-?)?(\([2-9]\d{2}\)|[2-9]\d{2})-?[2-9]\d{2}-?\d{4}$/) != nil
	end
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