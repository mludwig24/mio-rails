class Quote
	include ActiveModel::Model

	def initialize(quote_data=nil)
		if quote_data
			self.enter_date = quote_data.enter_date
			self.leave_date = quote.leave_date
			self.username = quote.username
			self.api_key = quote.api_key
			if quote.policy
				@policy = Policy.new(quote.policy)
			end
			@power_unit = PowerUnit.new(quote)
			@limits = Limits.new(quote)
		else
			self.enter_date = Date.today
			self.leave_date = Date.today
		end
	end

	attr_accessor :enter_date, :leave_date, :username,
		:api_key, :agtdst, :office_code, :power_unit
	attr_accessor :vehicle_type, :year, :make_id,
		:model_id, :value, :towing, :liability_limit,
		:fixed_deductibles, :body_style
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
		[50000, 10000, 300000, 500000]
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
