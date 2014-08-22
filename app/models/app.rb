class App < ActiveRecord::Base
	belongs_to :quote
	has_many :drivers, dependent: :destroy, class_name: 'Drivers'
	before_create :generate_token
	accepts_nested_attributes_for :drivers
	accepts_nested_attributes_for :quote

	def before_validation_on_create
		self.phone = phone.phone
	end

	attr_accessor :step
	
	def to_param
		self.token
	end

	def initialize(params)
		@step = 42 ## Default to higher than max.
		super(params)
	end

	## Go get the rates and cache them.
	def get_rates
		raise "Not valid!  Should not get here!" unless valid?
		## Create a rater object.
		@rates = Rater::Rater.new(self.quote)
		@rates.api_call(Rater::FormatterApp_v3, Rater::Transporter_v3)
		return @rates
	end

	def self.valid_us_states ## For validation farther down.
		AppsController.helpers.us_states.map{|x| x[1]} # ["State", "State Code"]
	end
	def valid_us_states; self.class.us_states end

	def self.valid_ownerships
		[
			"financed",
			"leased",
			"owned",
			"other_owner",
			"rental",
		]
	end
	def valid_ownerships; return self.class.valid_ownerships() end

	validates_presence_of :uid, :tid
	validates_presence_of :first_name, :last_name, :address, :city, :state,
		:zip, :phone, :email, :license_number, :license_state,
		:if => Proc.new { |app| app.validate_personal? }
	validates :state, :inclusion => valid_us_states,
		:if => Proc.new { |app| app.validate_personal? }
	validates :email, :email => {:strict_mode => true},
		:if => Proc.new { |app| app.validate_personal? }
	validates :phone, :phone => true,
		:if => Proc.new { |app| app.validate_personal? }
	validates :license_state, :inclusion => valid_us_states,
		:if => Proc.new { |app| app.validate_personal? }
	validates_presence_of :vin, :registration, :us_insurance_company,
		:us_insurance_policy, :us_insurance_expiration, :ownership,
		:license_plate, :license_plate_state,
		:if => Proc.new { |app| app.validate_personal? }
	validates_presence_of :finance_company, :finance_account,
		:finance_address, :finance_city, :finance_state, :finance_zip,
		:if => Proc.new { |app| app.validate_finance? }
	validates :finance_state, :inclusion => valid_us_states,
		:if => Proc.new { |app| app.validate_finance? }
	validates :license_plate_state, :inclusion => valid_us_states,
		:if => Proc.new { |app| app.validate_personal? }
	validates :us_insurance_expiration, :date => {
		:after => Proc.new { Date.today },
		:before => Proc.new { Date.today + 5.years }, ## 90 days is too far.
	}, :if => Proc.new { |app| app.validate_personal? }
	validates :ownership, :inclusion => {:in => Proc.new { 
			App.valid_ownerships() }},
		:if => Proc.new { |app| app.validate_personal? }

	protected

	def validate_personal?
		self.step >= 1
	end
	def validate_vehicle?
		self.step >= 2
	end
	def validate_finance?
		self.step >= 2 and %w{leased financed}.include?(self.ownership)
	end
	def generate_token
		self.token = loop do
			random_token = SecureRandom.urlsafe_base64(8, false).downcase
			break random_token unless Quote.exists?(token: random_token)
		end
	end
end