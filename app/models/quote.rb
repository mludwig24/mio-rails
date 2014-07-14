class Quote
	include ActiveModel::Model
	
	def initialize(quote_data=nil)
		if quote_data
			@enter_date = quote_data.enter_date
			@leave_date = quote.leave_date
			@username = quote.username
			@api_key = quote.api_key
			if quote.policy
				@policy = Policy.new(quote.policy)
			end
			@power_unit = PowerUnit.new(quote)
			@limits = Limits.new(quote)
		else
			@enter_date = Date.today
			@leave_date = Date.tomorrow
		end
	end

	attr_accessor :enter_date, :leave_date, :username,
		:api_key, :agtdst, :office_code, :power_unit
	attr_accessor :vehicle_type, :year, :make_id,
		:model_id, :value, :towing, :liability_limit,
		:fixed_deductibles, :body_style, :beyond_freezone,
		:under21, :uscoll_sc, :days_veh_in_mexico,
		:visit_reason
	validates_presence_of :enter_date, :leave_date, 
		:username, :api_key
	validates_date :enter_date, :leave_date
	validate :validate_enter_date

	def valid_years
		years = ((Date.today.year - 35)..Date.today.year).to_a
		if Date.today.month >= 4
			years << Date.today.year + 1
		end
		return years
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

	def validate_enter_date
		errors.add("Enter date", "is invalid") unless 
			valid_enter_date?
	end

	def valid_enter_date?
		false # TODO:  Make this work.
	end	

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
