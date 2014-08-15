class App < ActiveRecord::Base
	belongs_to :quote
	before_create :generate_token

	attr_accessor :step
	def initialize(params)
		@step = 42 ## Default to higher than max.
		super(params)
	end

	def self.us_states
		AppsController.helpers.us_states
	end
	def us_states; self.class.us_states end

	validates_presence_of :uid, :tid
	validates_presence_of :first_name, :last_name, :address, :city, :state,
		:zip, :phone, :email, :license_number, :license_state,
		:unless => Proc.new { |app| app.step < 1 }
	validates :state, :inclusion => us_states,
		:unless => Proc.new { |app| app.step < 1 }
	validates :license_state, :inclusion => us_states,
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