class QuotesController < ApplicationController
	before_filter :prepare_for_mobile
	def show
		id = params[:id]
		@quote = Quote.find(id)
		@quote.valid?
	end
	def new
		@quote = Quote.new
	end
	def update
		@quote = Quote.find(params[:id])
		@quote.update(quote_params)
		if @quote.valid?
			## Redirect.
			@quote.save
			redirect_to action: 'results', token: @quote.token
		else
			render "new"
		end
	end
	def results
		@quote = Quote.find_by(token: params[:token])
		if !@quote.valid?
			redirect_to quote_url(@quote)
		end
		@rates = @quote.get_rates()
		render "results"
	end
	def create
		@quote = Quote.create(quote_params)
		if @quote.valid?
			## Redirect.
			@quote.save()
			redirect_to action: 'results', token: @quote.token
		else
			render "new"
		end
	end
	def index
		@quote = Quote.new
		render "new"
	end
	private
	def quote_params
		params.require(:quote).permit(
			:enter_date, :leave_date, :vehicle_type, :year, :make_id, 
			:model_id, :value, :towing, :liability_limit, 
			:fixed_deductibles, :body_style, :other_model, :liability, 
			:extended_travel, :beyond_freezone, :under21, :uscoll_sc, 
			:days_veh_in_mexico, :visit_reason
		)
	end
end