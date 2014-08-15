require 'pp'
## Re-open the date class to help with the date_select form element.
class Date
	def self.new_from_date_select(hash, key)
		Date.new(hash["#{key}(1i)"].to_i,
			hash["#{key}(2i)"].to_i,
			hash["#{key}(3i)"].to_i)
	rescue
		return nil
	end
	def self.new_from_date_select!(hash, key)
		date = self.new_from_date_select(hash, key)
		if hash && hash.has_key?("#{key}(1i)")
			hash.delete("#{key}(1i)")
			hash.delete("#{key}(2i)")
			hash.delete("#{key}(3i)")
		end
		return date
	end
end

class Rater
	include ActiveModel::Model
	def initialize(quote, rates=nil)
		@quote = quote
		if rates
			@rates = rates
		else
			api_call()
		end
	end
	attr_accessor :api_data, :transport, :rates
	def api_call
		@api_data ||= format_quote_data(@quote)
		@rates = quote_api(@api_data.to_json)
	end
	def quote_api(json)
		@transport ||= Transport.new(json)
		@transport.res["rates"].each do |rate|
			self << rate
		end
	end
	def self.format_quote_data(quote, formatter=nil)
		unless formatter != nil
			formatter = Formatter_v3.new() ## Default
		end
		formatter.quote = quote
		@api_data = formatter.format()
	end
	def format_quote_data(quote)
		self.class.format_quote_data(quote)
	end
	def <<(val)
		@rates ||= Array.new()
        @rates << val
    end
	def each(rates=nil, &block)
		@rates.each(&block)
	end
	def select(&block)
		@rates.select(&block)
	end
	def count
		@rates.count
	end
	def columns
		@rates.count / @self.terms.count
	end
	def underwriters
		@rates.map { |x| x["underwriter_name"] }.uniq!
	end
	def for(field, value)
		rates = @rates.select { |r|
			r[field] == value
		}
		Rater.new(@quote, rates)
	end
	def for_underwriter(value)
		self.for("underwriter_name", value)
	end
	def coverages
		@rates.map { |x| x["underwriter_coverage_desc"] }.uniq!
	end
	def for_coverage(value)
		self.for("coverage", value)
	end
	def terms
		@rates.map { |x| x["term"] }.uniq!
	end
	def for_term(value)
		self.for("term", value)
	end

	private

	class Transport
		attr_accessor :res
		def initialize(options)
			@res = JSON.parse(query_remote(options).body)
		end
		def query_remote(json)
			@api_uri ||= URI("https://sb.iigins.com/api/quote.mhtml")
			req = Net::HTTP::Post.new(@api_uri.path)
			req.set_form_data({'data' => json})
			sock = Net::HTTP.new(@api_uri.host, @api_uri.port)
			sock.use_ssl = true ## Required for SSL server port.
			sock.start { |http|
				http.request(req)
			}
		end
	end
	class Formatter
		def initialize(quote=nil)
			@quote = quote
		end
		def format
			raise "Not yet implemented.  Please extend this object first."
		end
		def quote=(quote)
			@quote = quote
		end
	end
	class Formatter_v3 < Formatter
		def format
			api_data = Hash.new()
			## API Key info.
			api_data["auth"] = Hash.new()
			api_data["auth"]["username"] = ENV["mio_api_username"]
			api_data["auth"]["api_key"] = ENV["mio_api_key"]
			## Travel Dates.
			api_data["quote"] = Hash.new()
			api_data["quote"]["effective_date"] = @quote.enter_date.strftime("%m%d%Y")
			api_data["quote"]["expiration_date"] = @quote.leave_date.strftime("%m%d%Y")
			## Limits.
			api_data["limits"] = Hash.new()
			api_data["limits"]["liability"] = @quote.liability_limit.to_i
			api_data["limits"]["extended_travel"] = true ## Always include MexVisit.
			## Power Unit.
			api_data["power_unit"] = Hash.new()
			api_data["power_unit"]["type"] = "power" # Always.
			api_data["power_unit"]["year"] = @quote.year
			api_data["power_unit"]["style"] = @quote.vehicle_type
			api_data["power_unit"]["make"] = @quote.make_id
			api_data["power_unit"]["model"] = @quote.model_id
			api_data["power_unit"]["value"] = @quote.value.to_i
			## Underwriting.
			api_data["underwriting"] = Hash.new()
			api_data["underwriting"]["drivers_under_21"] = @quote.under21.to_i == 1
			api_data["underwriting"]["collision_in_us"] = @quote.uscoll_sc.to_i == 1
			api_data["underwriting"]["fixed_deductible"] = @quote.fixed_deductibles.to_i == 1
			api_data["underwriting"]["beyond_freezone"] = @quote.beyond_freezone.to_i == 1
			api_data["underwriting"]["days_veh_in_mexico"] = @quote.days_veh_in_mexico.to_i
			api_data["underwriting"]["visit_reason"] = @quote.visit_reason.to_i
			## PolicyHolder.
			api_data["policyholder"] = Hash.new()
			api_data["policyholder"]["license_state"] = "CA"
			## Drivers.
			api_data["drivers"] = Array.new()
			## Towed.
			api_data["towed"] = Array.new()
			return api_data
		end
	end

end

class Quote < ActiveRecord::Base
	before_create :generate_token
	has_many :toweds, dependent: :destroy
	has_one :app, dependent: :destroy
	accepts_nested_attributes_for :toweds
	
	validates :fixed_deductibles, :presence => true,
		:inclusion => {:in => [0, 1]}
	validates :liability_limit, :presence => true,
		:inclusion => {:in => Proc.new { 
			Quote.valid_liability_limits() }}
	validates :under21, :presence => true,
		:inclusion => {:in => [0, 1]}
	validates :beyond_freezone, :presence => true,
		:inclusion => {:in => [0, 1]}
	validates :uscoll_sc, :presence => true,
		:inclusion => {:in => [0, 1]}
	validates :days_veh_in_mexico, :presence => true,
		:inclusion => {:in => Proc.new { 
			Quote.valid_days_veh_in_mexico() }}
	validates :visit_reason, :presence => true,
		:inclusion => {:in => Proc.new { 
			Quote.valid_visit_reasons() }}
	validates_presence_of :enter_date, :leave_date, :vehicle_type, :year, :make_id, :value
	validates :model_id, presence: true, allow_blank: false, unless: "other_model.present?"
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

	def get_rates
		raise "Not valid!  Should not get here!" unless valid?
		## Create a rater object.
		@rates ||= Rater.new(self)
		return @rates
	end

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
	def self.valid_liability_limits
		[50000, 100000, 300000, 500000]
	end
	def valid_liability_limits
		return self.class.valid_liability_limits()
	end
	def self.valid_visit_reasons
		[
			1, # Driving to Vacation Destination/Tourist Visa
			2, # Visiting Friends or Family
			3, # Business/Work/School/Frequent Commuter
			4, # Temporary Mexico Resident Visa Holder
			5,  # Permanent Mexico Resident Visa Holder
		]
	end
	def valid_visit_reasons
		return self.class.valid_visit_reasons()
	end
	def self.valid_days_veh_in_mexico
		[
			1, # Less than 30
			2, # Between 31 and 90
			3, # Between 90 and 180
			4, # More than 180
		]
	end
	def valid_days_veh_in_mexico
		return self.class.valid_days_veh_in_mexico()
	end

	protected

	def generate_token
		self.token = loop do
			random_token = SecureRandom.urlsafe_base64(8, false).downcase
			break random_token unless Quote.exists?(token: random_token)
		end
	end
end
