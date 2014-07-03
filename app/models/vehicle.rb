class Vehicle
	require 'json'
	require 'net/http'
	def initialize(options)
		@type = options[:type]
		@vehicle_type = options[:vehicle_type]
		@make = options[:make]
		@model = options[:model]
		getNextList(options)
	end
	def addTypes(types)
		@types = types
	end
	def addVehicleTypes(vehicle_types)
		@vehicle_types = vehicle_types
	end
	def addMakes(makes)
		@makes = makes
	end
	def addModels(models)
		@models = models
	end
	def addBodyStyles(body_styles)
		@body_styles = body_styles
	end

	private

	def getNextList(options)
		transport = Transport.new(options)
		nextKey = transport.nextOption
		case nextKey
		when :vehicle_types
			addVehicleTypes(transport.vehicle_types)
		when :makes
			addMakes(transport.makes)
		when :models
			addModels(transport.models)
		when :body_styles
			addBodyStyles(transport.body_styles)
		else # Default to :types
			addTypes(transport.types)
		end
	end

	class Transport
		attr_accessor :res, :types, :vehicle_types, :makes,
			:models, :body_styles
		def initialize(options)
			@res = JSON.parse(query_remote(options).body)
		end
		def nextOption
			if @res.has_key?('vehicle_types')
				@vehicle_types = @res['vehicle_types']
				return :vehicle_types
			elsif @res.has_key?('makes')
				@makes = @res['makes']
				return :makes
			elsif @res.has_key?('models')
				@models = @res['models']
				return :models
			elsif @res.has_key?('body_styles')
				@body_styles = @res['body_styles']
				return :body_styles
			end
			@types = @res['types']
			return :types
		end
		def query_remote(params)
			@api_uri ||= URI("http://sb.iigins.com/api/make_model.mhtml")
			@api_uri.query = URI.encode_www_form(params)
			Net::HTTP.get_response(@api_uri)
		end
	end
end