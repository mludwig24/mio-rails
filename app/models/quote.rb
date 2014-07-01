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
		end
	end

	attr_accessor :enter_date, :leave_date, :username,
		:api_key, :agtdst, :office_code, :power_unit
	attr_accessor :vehicle_type, :year, :make_id,
		:model_id, :value, :towing, :liability_limit,
		:fixed_deductibles
	validates_presence_of :enter_date, :leave_date, 
		:username, :api_key
	validates_date :enter_date, :leave_date
	validate :validate_enter_date

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
