require 'pp'
class Rater
	include ActiveModel::Model
	attr_accessor :api_data, :transport, :rates, :formatter
	## `rates` are sent when creating a sub-set of rates.
	## For example, rates for "GNP Extended".
	def initialize(quote, rates=nil)
		@quote = quote
		if rates
			@rates = rates
		else
			api_call()
		end
	end
	## Setup and call the API.
	def api_call(formatter=nil, transport=nil)
		@api_data ||= format_quote_data(@quote)
		@rates = transport_api(@api_data.to_json)
	end
	## Do the actual API call.
	def transport_api(json, transport=nil)
		if transport == nil
			transport = Transport_v3
		end
		@transport ||= transport.new(json)
		@rates = @transport.res["rates"]
	end
	## Format ourself into the correct json for @api_data.
	def self.format_quote_data(quote, formatter=nil)
		if formatter == nil
			formatter = Formatter_v3 ## Default
		end
		@formatter ||= formatter.new()
		@formatter.quote = quote
		@api_data = @formatter.format()
	end
	def format_quote_data(quote, formatter=nil)
		self.class.format_quote_data(quote, formatter)
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
	## Get a list of underwriters.
	## Does not break down by coverage (Extended vs Standard).
	def underwriters
		@rates.map { |x| x["underwriter_name"] }.uniq
	end
	## Create a new sub-set of raters.
	def for(field, value)
		rates = @rates.select { |r|
			r[field] == value
		}
		## Specify the rates to `initialize`, so we don't call
		## the API again.
		Rater.new(@quote, rates)
	end
	def for_underwriter(value) ## Proxy to "for".
		self.for("underwriter_name", value)
	end
	def coverages ## List of coverage options.  Stupid plural.
		@rates.map { |x| x["underwriter_coverage_desc"] }.uniq
	end
	def for_coverage(value) ## Proxy to "for".
		self.for("coverage", value)
	end
	def terms ## List of terms.
		@rates.map { |x| x["term"] }.uniq
	end
	def for_term(value) ## Proxy to "for".
		self.for("term", value)
	end

	private

	class Transport ## How do we send this to the server?
		attr_accessor :res
		def initialize(options)
			@res = JSON.parse(query_remote(options).body)
		end
		def query_remote(json)
			raise "Not yet implemented.  Please extend this object first."
		end
	end
	class Transport_v3 < Transport ## v3 specific version.
		def query_remote(json)
			@api_uri ||= URI("#{ENV["mio_api_url"]}/quote.mhtml")
			req = Net::HTTP::Post.new(@api_uri.path)
			req.set_form_data({'data' => json})
			sock = Net::HTTP.new(@api_uri.host, @api_uri.port)
			## Force SSL if necessary.
			sock.use_ssl = @api_uri.scheme == "https"
			sock.start { |http|
				http.request(req)
			}
		end
	end
	class Formatter ## Base formatter for sending data.
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
