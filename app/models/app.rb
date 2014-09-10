class App < ActiveRecord::Base
	belongs_to :quote
	has_many :drivers, dependent: :destroy, class_name: 'Drivers'
	before_create :generate_token
	accepts_nested_attributes_for :drivers
	accepts_nested_attributes_for :quote

	attr_reader :cc_num, :cc_exp, :policy, :rates, :signer, :agreement
	def cc_num=(cc_num)
		raise "Should never try to set a credit card number!"
	end
	def cc_exp=(cc_num)
		raise "Should never try to set a credit card number!"
	end

	def before_validation_on_create
		self.phone = phone.phone
	end

	attr_accessor :step, :policy
	
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
		@rates = Rater::Quote.new(self.quote)
		@rates.api_call(Rater::FormatterApp_v3, Rater::Transporter_v3)
		return @rates
	end
	def get_policy
		if self.v3_policy_id == nil ## Create a new policy.
			@rate = Rater::CreatePolicy.new(self.quote)
			@rate.api_call(Rater::FormatterAppPolicy_v3, Rater::Transporter_v3)
			if @rate.errors
				return @rate
			else
				self.v3_policy_id = @rate.res["policy"]["policy_id"]
				self.save()
			end
		end
		@policy = Rater::Policy.new(self)
		@policy.api_call(Rater::FormatterPolicy_v3, Rater::TransporterPolicy_v3)
		return @policy
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

	def self.financed?(ownership)
		["financed", "leased"].include?(ownership)
	end
	def financed?
		return self.class.financed?(self.ownership)
	end

	def valid_signers
		result = ["#{self.first_name} #{self.last_name}".titleize,]
		self.drivers.each do |driver|
			result << "#{driver.first_name} #{driver.last_name}".titleize
		end
		return result
	end

	validates_presence_of :uid, :tid
	validates_presence_of :first_name, :last_name, :address, :city, :state,
		:zip, :phone, :email, :license_number,
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
		:us_insurance_policy, :us_insurance_expiration, :license_plate,
		:if => Proc.new { |app| app.validate_vehicle? }
	validates :registration, :inclusion => valid_us_states,
		:if => Proc.new { |app| app.validate_vehicle? }
	validates_presence_of :finance_company, :finance_account,
		:finance_address, :finance_city, :finance_zip,
		:if => Proc.new { |app| app.validate_finance? }
	validates :finance_state, :inclusion => valid_us_states,
		:if => Proc.new { |app| app.validate_finance? }
	validates :license_plate_state, :inclusion => valid_us_states,
		:if => Proc.new { |app| app.validate_vehicle? }
	validates :us_insurance_expiration, :date => {
		:after => Proc.new { Date.today },
		:before => Proc.new { Date.today + 5.years }, ## 90 days is too far.
	}, :if => Proc.new { |app| app.validate_vehicle? }
	validates :ownership, :inclusion => {:in => Proc.new { 
			App.valid_ownerships() }},
		:if => Proc.new { |app| app.validate_vehicle? }

	protected

	def validate_personal?
		self.step >= 1
	end
	def validate_vehicle?
		self.step >= 2
	end
	def validate_finance?
		self.step >= 2 and self.financed?
	end
	def generate_token
		self.token = loop do
			random_token = SecureRandom.urlsafe_base64(8, false).downcase
			break random_token unless Quote.exists?(token: random_token)
		end
	end
end