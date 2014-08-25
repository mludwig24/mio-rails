require 'pp'
module Rater
	class Rater
		include ActiveModel::Model
		attr_accessor :api_data, :transporter, :formatter, :errors, :res, :data
		## `rates` are sent when creating a sub-set of rates.
		## For example, rates for "GNP Extended".
		def initialize(data_obj, data=nil)
			@data_obj = data_obj
			@data = data || []
		end
		## Setup and call the API.
		def api_call(formatter=Transporter, transporter=Formatter)
			@api_data ||= format_data(@data_obj, formatter)
			transporter_api(@api_data.to_json, transporter)
			return process_response(@transporter.res)
		end
		def process_response(res)
			@res = res
			@errors = res["errors"]
			@data = res
			return @data
		end
		## Do the actual API call.
		def transporter_api(json, transporter)
			@transporter ||= transporter.new(json)
		end
		## Format ourself into the correct json for @api_data.
		def self.format_data(data_obj, formatter)
			@formatter = formatter.new()
			@formatter.data_obj = data_obj
			@api_data = @formatter.format()
		end
		def format_data(data_obj, formatter=nil)
			self.class.format_data(data_obj, formatter)
		end
	end
	class Quote < Rater
		attr_accessor :rate, :quote_id, :client_key, :policy
		def process_response(res)
			@res = res
			@errors = res["errors"]
			if res.has_key?("quote")
				@quote_id = res["quote"]["quote_id"]
			end
			if res.has_key?("payment") and 
					res["payment"].has_key?("client_key")
				@client_key = res["payment"]["client_key"]
			end
			@data = res["rates"]
			@policy = res["policy"]
			@rate = res["rate"]
			return @data ? @data : @rate
		end
		def each(rates=nil, &block)
			@data.each(&block)
		end
		def select(&block)
			@data.select(&block)
		end
		def count
			@data.count
		end
		def columns
			@data.count / @self.terms.count
		end
		## Get a list of underwriters.
		## Does not break down by coverage (Extended vs Standard).
		def underwriters
			@data.map { |x| x["underwriter_name"] }.uniq
		end
		## Create a new sub-set of raters.
		def for(field, value)
			rates = @data.select { |r|
				r[field] == value
			}
			## Specify the rates to `initialize`, so we don't call
			## the API again.
			Quote.new(@data_obj, rates)
		end
		def for_underwriter(value) ## Proxy to "for".
			self.for("underwriter_name", value)
		end
		def coverages ## List of coverage options.  Stupid plural.
			@data.map { |x| x["underwriter_coverage_desc"] }.uniq
		end
		def for_coverage(value) ## Proxy to "for".
			self.for("coverage", value)
		end
		def terms ## List of terms.
			@data.map { |x| x["term"] }.uniq
		end
		def for_term(value) ## Proxy to "for".
			self.for("term", value)
		end
	end
	class Policy < Rater
		include ActiveModel::Model
		def process_response(res)
			@data = @transporter.res["policy"]
			return @data
		end
	end
	class Formatter ## Base formatter for sending data.
		def initialize(data_obj=nil)
			@data_obj = data_obj
		end
		def format
			raise "Not yet implemented.  Please extend this object first."
		end
		def data_obj=(data_obj)
			@data_obj = data_obj
		end
	end
	class FormatterQuote_v3 < Formatter
		@@date_format = "%m%d%Y"
		def format
			api_data = Hash.new()
			## API Key info.
			api_data["auth"] = Hash.new()
			api_data["auth"]["username"] = ENV["mio_api_username"]
			api_data["auth"]["api_key"] = ENV["mio_api_key"]
			## Travel Dates.
			api_data["quote"] = Hash.new()
			api_data["quote"]["effective_date"] = @data_obj.enter_date.strftime(@@date_format)
			api_data["quote"]["expiration_date"] = @data_obj.leave_date.strftime(@@date_format)
			if @data_obj.api_quote_id != nil
				api_data["quote"]["quote_id"] = @data_obj.api_quote_id
			end
			## Limits.
			api_data["limits"] = Hash.new()
			api_data["limits"]["liability"] = @data_obj.liability_limit.to_i
			api_data["limits"]["extended_travel"] = true ## Always include MexVisit.
			## Power Unit.
			api_data["power_unit"] = Hash.new()
			api_data["power_unit"]["type"] = "power" # Always.
			api_data["power_unit"]["year"] = @data_obj.year
			api_data["power_unit"]["style"] = @data_obj.vehicle_type
			api_data["power_unit"]["make"] = @data_obj.make_id
			api_data["power_unit"]["model"] = @data_obj.model_id
			api_data["power_unit"]["value"] = @data_obj.value.to_i
			## Underwriting.
			api_data["underwriting"] = Hash.new()
			api_data["underwriting"]["drivers_under_21"] = @data_obj.under21.to_i == 1
			api_data["underwriting"]["collision_in_us"] = @data_obj.uscoll_sc.to_i == 1
			api_data["underwriting"]["fixed_deductible"] = @data_obj.fixed_deductibles.to_i == 1
			api_data["underwriting"]["beyond_freezone"] = @data_obj.beyond_freezone.to_i == 1
			api_data["underwriting"]["days_veh_in_mexico"] = @data_obj.days_veh_in_mexico.to_i
			api_data["underwriting"]["visit_reason"] = @data_obj.visit_reason.to_i
			## PolicyHolder.
			api_data["policyholder"] = Hash.new()
			api_data["policyholder"]["license_state"] = "CA"
			## Towed.
			api_data["towed"] = Array.new()
			@data_obj.toweds.each do |towed|
				api_data["towed"] << {
					type: towed.type_id,
					year: towed.year,
					value: towed.value,
				}
			end
			return api_data
		end
	end
	class FormatterApp_v3 < FormatterQuote_v3
		def format
			api_data = super
			api_data["policy"] = Hash.new()
			api_data["policy"]["underwriter_id"] = @data_obj.app.uid
			api_data["policy"]["term"] = @data_obj.app.tid
			## Power Unit.
			api_data["power_unit"]["vin"] = @data_obj.app.vin
			api_data["power_unit"]["registration"] = @data_obj.app.registration
			api_data["power_unit"]["us_insurance_company"] = @data_obj.app.us_insurance_company
			api_data["power_unit"]["us_insurance_policy"] = @data_obj.app.us_insurance_policy
			api_data["power_unit"]["us_insurance_expiration"] = @data_obj.app.us_insurance_expiration.strftime(@@date_format)
			api_data["power_unit"]["license_plate"] = @data_obj.app.license_plate
			api_data["power_unit"]["license_plate_state"] = @data_obj.app.license_plate_state
			api_data["power_unit"]["ownership"] = @data_obj.app.ownership
			if @data_obj.app.financed?
				api_data["power_unit"]["finance_company"] = @data_obj.app.finance_company
				api_data["power_unit"]["finance_account"] = @data_obj.app.finance_account
				api_data["power_unit"]["finance_address"] = @data_obj.app.finance_address
				api_data["power_unit"]["finance_city"] = @data_obj.app.finance_city
				api_data["power_unit"]["finance_state"] = @data_obj.app.finance_state
				api_data["power_unit"]["finance_zip"] = @data_obj.app.finance_zip
			end
			## Policyholder
			api_data["policyholder"]["first_name"] = @data_obj.app.first_name
			api_data["policyholder"]["last_name"] = @data_obj.app.last_name
			api_data["policyholder"]["address"] = @data_obj.app.address
			api_data["policyholder"]["city"] = @data_obj.app.city
			api_data["policyholder"]["state"] = @data_obj.app.state
			api_data["policyholder"]["zip"] = @data_obj.app.zip
			api_data["policyholder"]["phone"] = @data_obj.app.phone
			api_data["policyholder"]["email"] = @data_obj.app.email
			api_data["policyholder"]["license_number"] = @data_obj.app.license_number
			api_data["policyholder"]["license_state"] = @data_obj.app.license_state
			## Drivers
			api_data["drivers"] = Array.new()
			@data_obj.app.drivers.each do |driver|
				api_data["drivers"] << {first_name: driver.first_name, last_name: driver.last_name}
			end
			## Towed
			@data_obj.toweds.each_index do |i|
				towed = @data_obj.toweds[i]
				api_data["towed"][i] = {
					type: towed.type_id,
					year: towed.year,
					value: towed.value,
					make: towed.make,
					model: towed.model,
					license_plate: towed.license_plate,
					license_plate_state: towed.license_plate_state,
					vin: towed.vin,
				}
			end
			## Payment
			api_data["payment"] = Hash.new()
			api_data["payment"]["type"] = "credit_card"
			return api_data
		end
	end
	class FormatterAppPolicy_v3 < FormatterApp_v3
		def format
			api_data = super
			api_data["payment"]["nonce"] = @data_obj.app.payment_method_nonce
			return api_data
		end
	end
	class FormatterPolicy_v3 < FormatterApp_v3
		def format
			api_data = Hash.new()
			## API Key info.
			api_data["auth"] = Hash.new()
			api_data["auth"]["username"] = ENV["mio_api_username"]
			api_data["auth"]["api_key"] = ENV["mio_api_key"]
			api_data["policy"] = Hash.new()
			api_data["policy"]["policy_id"] = @data_obj.v3_policy_id
			return api_data
		end
	end
	class Transporter ## How do we send this to the server?
		attr_accessor :res
		def initialize(options)
			@res = JSON.parse(query_remote(options).body)
		end
		def query_remote(json)
			raise "Not yet implemented.  Please extend this object first."
		end
	end
	class Transporter_v3 < Transporter ## v3 specific version.
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
	class TransporterPolicy_v3 < Transporter ## v3 specific version.
		def query_remote(json)
			@api_uri ||= URI("#{ENV["mio_api_url"]}/policy.mhtml")
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
end