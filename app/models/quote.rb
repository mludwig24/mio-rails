class Quote < ActiveRecord::Base
	before_create :generate_token
	has_one :app, dependent: :destroy
	has_many :toweds, dependent: :destroy
	accepts_nested_attributes_for :toweds
	
	validates :fixed_deductibles,
		:inclusion => {:in => [0, 1]}
	validates :liability_limit,
		:inclusion => {:in => Proc.new { 
			Quote.valid_liability_limits() }}
	validates :under21,
		:inclusion => {:in => [0, 1]}
	validates :beyond_freezone,
		:inclusion => {:in => [0, 1]}
	validates :uscoll_sc,
		:inclusion => {:in => [0, 1]}
	validates :days_veh_in_mexico,
		:inclusion => {:in => Proc.new { 
			Quote.valid_days_veh_in_mexico() }}
	validates :visit_reason,
		:inclusion => {:in => Proc.new { 
			Quote.valid_visit_reasons() }}
	validates_presence_of :enter_date, :leave_date, :vehicle_type, :year,
		:make_id, :make_label, :value
	validates :model_id, presence: true, allow_blank: false, unless: "other_model.present?"
	validates :model_label, presence: true, allow_blank: false, unless: "other_model.present?"
	validates :other_model, presence: true, allow_blank: false, unless: "model_id.present?"

	validates :leave_date, :date => {
		:after_or_equal_to => :enter_date,
		## 1 year days is too far.
		:before => Proc.new { Date.today + 366 }}
	validates :enter_date, :date => {
		:after_or_equal_to => Proc.new { Date.today },
		:before => Proc.new { Date.today + 90 }, ## 90 days is too far.
	}
	validates :year, numericality: { only_integer: true },
		:inclusion => {:in => Proc.new { 
			Quote.valid_years() } }

	## Used to keep the sequential ID out of the URL.
	def to_param
		self.token
	end

	def model ## Handles model_label or other_model.
		self.model_id.present? ? self.model_label : self.other_model
	end

	## Go get the rates and cache them.
	def get_rates
		raise "Not valid!  Should not get here!" unless valid?
		## Create a rater object.
		@rates = Rater::Quote.new(self)
		@rates.api_call(Rater::FormatterQuote_v3, Rater::Transporter_v3)
		if @rates.quote_id != nil
			self.api_quote_id = @rates.quote_id
			self.save()
		end
		return @rates
	end

	def self.valid_years
		years = ((Date.today.year - 35)..Date.today.year).to_a
		if Date.today.month >= 4
			years << Date.today.year + 1
		end
		return years
	end
	def valid_years; return self.class.valid_years() end

	def self.valid_values
		values = [0]
		(3..400).each do |x|
			values << x * 1000
		end
		return values
	end
	def valid_values; self.class.valid_values() end

	def self.valid_liability_limits
		[50000, 100000, 300000, 500000]
	end
	def valid_liability_limits; return self.class.valid_liability_limits() end

	def self.valid_visit_reasons
		[
			1, # Driving to Vacation Destination/Tourist Visa
			2, # Visiting Friends or Family
			3, # Business/Work/School/Frequent Commuter
			4, # Temporary Mexico Resident Visa Holder
			5,  # Permanent Mexico Resident Visa Holder
		]
	end
	def valid_visit_reasons; return self.class.valid_visit_reasons() end
	
	def self.valid_days_veh_in_mexico
		[
			1, # Less than 30
			2, # Between 31 and 90
			3, # Between 90 and 180
			4, # More than 180
		]
	end
	def valid_days_veh_in_mexico; return self.class.valid_days_veh_in_mexico() end

	protected

	def generate_token
		self.token = loop do
			random_token = SecureRandom.urlsafe_base64(8, false).downcase
			break random_token unless Quote.exists?(token: random_token)
		end
	end
end
