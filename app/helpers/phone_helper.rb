module PhoneHelper
end

class String
	def raw_phone
		digits = self.gsub(/\D/, '').split(//)

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