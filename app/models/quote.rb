## Re-open the date class to help with the date_select form element.
class Date
	def self.new_from_date_select(hash, key)
		Date.new(hash["#{key}(1i)"].to_i,
			hash["#{key}(2i)"].to_i,
			hash["#{key}(3i)"].to_i)
	end
end

class Quote
	include ActiveModel::Model
	
	def initializeFoo(quote_data=nil)
		if quote_data
			@enter_date = Date.new_from_date_select(quote_data, 'enter_date')
			@leave_date = Date.new_from_date_select(quote_data, 'leave_date')
			@username = quote_data['username']
			@api_key = quote_data['api_key']
			if quote_data['policy']
				@policy = Policy.new(quote_data.policy)
			end
			@power_unit = PowerUnit.new(quote_data)
			@limits = Limits.new(quote_data)
		end
	end

	attr_accessor :enter_date, :leave_date, :username,
		:api_key, :agtdst, :office_code, :power_unit
	attr_accessor :vehicle_type, :year, :make_id,
		:model_id, :value, :towing, :liability_limit,
		:fixed_deductibles, :body_style, :beyond_freezone,
		:under21, :uscoll_sc, :days_veh_in_mexico,
		:visit_reason, :other_model
	validates :leave_date, :date => {
		:after_or_equal_to => :enter_date,
		:before => Proc.new { Date.today + 365 }, ## 1 year days is too far.
	}
	validates :enter_date, :date => {
		:after_or_equal_to => Proc.new { Date.today },
		:before => Proc.new { Date.today + 90 }, ## 90 days is too far.
	}
	validates :year, numericality: { only_integer: true },
		:inclusion => {:in => Proc.new { self.valid_years() } }

	def self.valid_years
		years = ((Date.today.year - 35)..Date.today.year).to_a
		if Date.today.month >= 4
			years << Date.today.year + 1
		end
		return years
	end
	def valid_years
		return self.class.valid_years()
	end
	def valid_values
		values = [0]
		(3..400).each do |x|
			values << x * 1000
		end
		return values
	end
	def valid_liability_limits
		[50000, 100000, 300000, 500000]
	end
	def valid_visit_reasons
		[
			1, # Driving to Vacation Destination/Tourist Visa
			2, # Visiting Friends or Family
			3, # Business/Work/School/Frequent Commuter
			4, # Temporary Mexico Resident Visa Holder
			5,  # Permanent Mexico Resident Visa Holder
		]
	end
	def valid_days_veh_in_mexico
		[
			1, # Less than 30
			2, # Between 31 and 90
			3, # Between 90 and 180
			4, # More than 180
		]
	end

	private

	class Policy
		include ActiveModel::Model
		attr_accessor :underwriter_id, :term
	end
	class Limits
		include ActiveModel::Model
		attr_accessor :liability, :extended_travel
	end
	class PowerUnit
		include ActiveModel::Model
		@type = "power"
		attr_accessor  :style, :year, :make, :model
			:value
		validates_presence_of :style, :year, :make,
			:model, :value
	end
end
