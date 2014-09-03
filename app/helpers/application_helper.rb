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
# See:  https://github.com/bootstrap-ruby/rails-bootstrap-forms
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
	class FormBuilder
		def radio_button(name, value, *args)
			options = args.extract_options!.symbolize_keys!
			args << options.except(:label, :help, :inline, :label_class, :label_checked_class)
			## Add a class if this is the "active" radio button.
			if @object.has_attribute?(name) and @object.send(name).to_s == value.to_s
				options[:label_class] = options[:label_class].to_s + " " + options[:label_checked_class].to_s
			end
			## Add the glyphicon class for mobile "buttons" support.  Add this support via CSS.
			html = super + content_tag(:span, "", class: "glyphicon") + content_tag(:span, options[:label])
			if options[:inline]
				label(name, html, class: options[:label_class].to_s + " radio-inline", value: value)
			else
				content_tag(:div, class: "radio") do
					label(name, html, value: value, class: options[:label_class].to_s)
				end
			end
		end
		def generate_help(name, help_text)
			help_text = object.errors[name].join(", ") if has_error?(name) && inline_errors
			return if help_text === false
			help_text ||= I18n.t(name, scope: "activerecord.help.#{object.class.to_s.downcase}", default: '')
			help_tag = content_tag(:span, help_text.html_safe, {class: 'help-block', "data-toggle" => "modal"}) if help_text.present?
			help_pop_text = I18n.t(name, scope: "activerecord.help.popup.#{object.class.to_s.downcase}", default: '')
			if help_pop_text.present?
				help_pop_tag = content_tag(:div, help_pop_text.html_safe,
						class: "help-popup-content help-block",
						"data-help-popup-id" => "help-popup-#{object.class.to_s.downcase}-#{name}",
						"data-help-popup-for" => "#{object.class.to_s.downcase}_#{name}",
						"data-help-popup-title" => I18n.t(name, scope: "activerecord.attributes.#{object.class.to_s.downcase}"))
 				return help_tag ? help_tag + help_pop_tag : help_pop_tag
			end
			return help_tag
		end
	end
end
# Phone validation:
class PhoneValidator < ActiveModel::EachValidator
	@@default_options = {}
	def self.default_options
		@@default_options
	end
	def validate_each(record, attribute, value)
		options = @@default_options.merge(self.options)
		unless value.phone?
			record.errors.add(attribute, options[:message] || :invalid)
		end
	end
end