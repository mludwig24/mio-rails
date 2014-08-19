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

	validates_presence_of :uid, :tid
	validates_presence_of :first_name, :last_name, :address, :city, :state,
		:zip, :phone, :email, :license_number, :license_state,
		:unless => Proc.new { |app| app.step < 1 }
	validates :state, :inclusion => valid_us_states,
		:unless => Proc.new { |app| app.step < 1 }
	validates :email, :email => {:strict_mode => true},
		:unless => Proc.new { |app| app.step < 1 }
	validates :phone, :phone => true,
		:unless => Proc.new { |app| app.step < 1 }
	validates :license_state, :inclusion => valid_us_states,
		:unless => Proc.new { |app| app.step < 1 }
	validates_presence_of :vin, :registration, :us_insurance_company,
		:ownership,
		:unless => Proc.new { |app| app.step < 2 }

	protected

	def generate_token
		self.token = loop do
			random_token = SecureRandom.urlsafe_base64(8, false).downcase
			break random_token unless Quote.exists?(token: random_token)
		end
	end
end