require 'pp'
class AppsController < ApplicationController
	before_action :get_app
	def personal ## Personal information step.
		@app.step = 1
	end
	def vehicle ## Vehicle information step.
		@app.step = 2
	end
	def recap
		@app.step = 3
		unless @app.quote.valid?
			redirect_to quote_path(@app.quote) and return
		end
		unless @app.valid?
			redirect_to app_personal_path(@app) and return
		end
		@rate = @app.get_rates()
		if @rate.errors != nil
			flash[:error] = @rate.errors
		end
	end
	def policy
		@policy = @app.get_policy()
	end
	def new ## Transfer from the quote.
		## Save the tid, uid, and qid, and send them to Personal.
		@app.step = 0
		## Check for an update to the underwriter and/or term.
		@app.update(init_params)
		if @app.save()
			redirect_to app_personal_path(@app)
		end
	end
	def show ## Transfer from quotes with an existing app.
		@app.step = 0
		@app.update(init_params)
		if @app.valid?
			if @app.save()
				redirect_to app_personal_path(@app) and return
			end
		end
		render "personal"
	end
	## Saving changes, needs to be aware of the steps.
	def update
		@app.step = step
		if @app.step == 2
			@app.quote.toweds.each do |towed|
				towed.app_mode = true
			end
		end
		@app.update(app_params)
		if @app.valid?
			@app.save()
			if @app.step == 3 and @app.v3_policy_id == nil ## Issue the policy.
				@policy = @app.get_policy()
				if @policy.errors or @policy.data == nil
					@rate = @policy ## We got a quote back, not a policy.
					render "recap" and return
				end
			end
			next_step and return
		end
		## If the form was invalid:
		case @app.step
		when 1
			render "personal"
		when 2
			render "vehicle"
		when 3
			render "recap"
		end
	end
	def index
		## Don't need a list of apps.  Just get rid of them.
		redirect_to :root
	end

	private
	
	def get_app
		## Check for an :id, mostly for "update" method.
		if params.has_key?(:id)
			begin
				@app = App.find(params[:id])
			rescue
				@app = App.find_by_token(params[:id])
			end
		## Check for a :token, used for "personal", "vehicle", etc.
		elsif params.has_key?(:token)
			@app = App.find_by(token: params[:token])
		## Check for a :qid, which is mostly for the "new" method.
		elsif quote_token.has_key?(:qid)
			@quote = Quote.find_by(token: quote_token[:qid])
			@app = @quote.app
			if @app == nil
				@app = @quote.build_app
			end
		end
		## Just make sure we have an @quote for recaps and such.
		if @app != nil
			@quote = @app.quote
		end
	end
	## Checks the step to determine which parameters to use.
	def app_params
		case @app.step
		when 0
			return init_params
		when 1
			return personal_params
		when 2
			return vehicle_params
		when 3
			return payment_params
		else
			return vehicle_params ## Most inclusive.
		end
	end
	def personal_params
		params.require(:app).permit(:first_name, :last_name, :address, 
			:city, :state, :zip, :phone, :email, :license_number,
			:license_state,
			:drivers_attributes => [ :id, :first_name, :last_name ])
	end
	def vehicle_params
		params.require(:app).permit(:vin, :registration,
			:us_insurance_company, :us_insurance_policy,
			:us_insurance_expiration, :ownership, :license_plate,
			:license_plate_state, :finance_account, :finance_company,
			:finance_address, :finance_city, :finance_state,
			:finance_zip,
			:quote_attributes => [ :id, :toweds_attributes => [
				:id, :make, :model, :vin, :license_plate,
				:license_plate_state
			]]
		)
	end
	def payment_params
		params.permit(:payment_method_nonce)
	end
	def init_params
		params.permit(:uid, :tid)
	end
	def quote_token
		params.permit(:qid)
	end
	## Extract the current step from the form submission.
	def step
		params.permit(:step)[:step].to_i
	end
	## Redirect and increment the step.
	def next_step
		case @app.step
		when 1
			redirect_to app_vehicle_path(@app)
		when 2
			redirect_to app_recap_path(@app)
		when 3
			redirect_to app_policy_path(@app)
		end
		@app.step += 1
	end
end