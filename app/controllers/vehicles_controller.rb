class VehiclesController < ApplicationController
	require 'json'
	respond_to :json, :xml
	def proxy
		@vehicle = Vehicle.new(params)
		respond_to do |format|
			format.json { render :json => @vehicle }
			format.xml  { render :xml => @vehicle.to_xml }
			## Default to json even for HTML.
			format.html { render :json => @vehicle }
		end
	end
end
