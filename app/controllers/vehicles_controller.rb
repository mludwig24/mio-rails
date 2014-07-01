class VehiclesController < ApplicationController
	require 'net/http'
	require 'json'
	respond_to :json
	before_action :prep_remote
	def list
		@vehicles.addTypes @res['types']
		render :json => @vehicles
	end
	def type
		@vehicles.addVehicleTypes @res['vehicle_types']
		render :json => @vehicles
	end
	def vehicle_type
		@vehicles.addMakes @res['makes']
		render :json => @vehicles
	end
	def make
		@vehicles.addModels @res['models']
		render :json => @vehicles
	end
	def model
		@vehicles.addBodyStyles @res['body_styles']
		render :json => @vehicles
	end

	private
	def prep_remote
		@res = JSON.parse(query_remote(params).body)
		@vehicles = VehicleList.new(params)
	end
	def query_remote(params)
		@api_uri ||= URI("http://sb.iigins.com/api/make_model.mhtml")
		@api_uri.query = URI.encode_www_form(params)
		print @api_uri.inspect
		Net::HTTP.get_response(@api_uri)
	end
	class VehicleList
		require 'json'
		def initialize(options)
			@type = options[:type]
			@vehicle_type = options[:vehicle_type]
			@year = options[:year]
			@make = options[:make]
			@model = options[:model]
		end
		def addTypes(types)
			@types = types
		end
		def addVehicleTypes(vehicle_types)
			@vehicle_types = vehicle_types
		end
		def addYears(years)
			@years = years
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
	end
end
