class DriversController < ApplicationController
	before_action :get_app
	respond_to :xml, :json
	def index
		@drivers = @app.drivers
		respond_with(@drivers)
	end
	def show
		@drivers = @app.drivers.find(params[:id])
		respond_with(@drivers)
	end
	def new
		@driver = @app.drivers.build
		respond_with(@driver)
	end
	def create ## Create an individual object.
		@driver = @app.drivers.build(driver_params)
		if @driver.valid?
			@driver.save()
		end
		respond_with(@driver)
	end
	private
	def get_app
		@app = App.find_by_token(params[:token] ? params[:token] : params[:app_id])
	end
	def driver_params
		params.require(:drivers).permit(:first_name, :last_name)
	end
end
