class QuotesController < ApplicationController
	before_filter :prepare_for_mobile
	def show
		@quote = get_quote
		@quote.valid?
	end
	def new
		@quote = Quote.new
	end
	def update
		@quote = get_quote
		@quote.update(quote_params)
		if @quote.valid?
			## Redirect.
			@quote.save
			redirect_to quote_results_path(@quote)
		else
			render "new"
		end
	end
	def results
		@quote = get_quote
		if @quote == nil ## Not found.
			return redirect_to quote_path('')
		end
		unless @quote.valid? ## Invalid Quote.
			return redirect_to quote_url(@quote)
		end
		begin
			@rates = @quote.get_rates()
		rescue Exception => e
			logger.warn "#{@quote.id} threw error #{e.to_s}"
			@error = e
			render "api_error" and return
		end
		render "results"
	end
	def create
		@quote = Quote.create(quote_params)
		if @quote.valid?
			## Redirect.
			@quote.save()
			redirect_to quote_results_path(@quote)
		else
			render "new"
		end
	end
	def index
		@quote = Quote.new
		render "new"
	end
	private
	def get_quote
		## Check for an :id (which may be a token) mostly for
		## "update" method.
		if params.has_key?(:id)
			begin
				@quote = Quote.find(params[:id])
			rescue
				@quote = Quote.find_by_token(params[:id])
			end
		## Check for a :token.
		elsif params.has_key?(:token)
			@quote = Quote.find_by(token: params[:token])
		end
	end
	def quote_params
		params.require(:quote).permit(
			:enter_date, :leave_date, :vehicle_type, :year, :make_id, 
			:model_id, :value, :towing, :liability_limit, 
			:fixed_deductibles, :body_style, :other_model, :liability, 
			:extended_travel, :beyond_freezone, :under21, :uscoll_sc, 
			:days_veh_in_mexico, :visit_reason,
			:toweds_attributes => [ :id, :type_id, :type_label, :value, :year ]
		)
	end
end