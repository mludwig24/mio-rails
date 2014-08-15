class AppsController < ApplicationController
	before_action :get_app
	def personal
		@app.step = 1
	end
	def vehicle
		@app.step = 2
	end
	def new
		@app.step = 0
		if @app.new_record? and @app.valid?
			if @app.save()
				redirect_to action: 'personal', token: @app.token
			end
		end
	end
	def update
		@app.step = step
		@app.update(app_params)
		if @app.valid?
			@app.save()
			next_step and return
		end
		if step == 1
			render "personal" and return
		end
		render "vehicle"
	end
	def index
		redirect_to :root
	end

	private
	
	def get_app
		if params.has_key?(:id)
			@app = App.find(params[:id])
		elsif params.has_key?(:token)
			@app = App.find_by(token: params[:token])
		elsif quote_token.has_key?(:qid)
			@quote = Quote.find_by(token: quote_token[:qid])
			@app = @quote.app
			if @app == nil
				@app = @quote.build_app
			end
		end
		if @app != nil
			@quote = @app.quote
		end
		if app_params.has_key?(:uid) || app_params.has_key?(:tid)
			@app.uid = app_params[:uid]
			@app.tid = app_params[:tid]
		end
	end
	def app_params
		if @app.step == 1
			return personal_params
		elsif @app.step == 2
			return vehicle_params
		end
		return init_params
	end
	def personal_params
		params.require(:app).permit(:first_name, :last_name, :address, 
			:city, :state, :zip, :phone, :email, :license_number,
			:license_state)
	end
	def vehicle_params
		params.requite(:app).permit(:vin, :registration,
			:us_insurance_company, :ownership)
	end
	def init_params
		params.permit(:uid, :tid)
	end
	def quote_token
		params.permit(:qid)
	end
	def step
		params.permit(:step)[:step].to_i
	end
	def next_step
		if step == 1
			redirect_to action: 'vehicle', token: @app.token
		end
		@app.step += 1
	end
end