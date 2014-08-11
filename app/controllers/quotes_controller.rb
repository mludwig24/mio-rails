class QuotesController < ApplicationController
	before_filter :prepare_for_mobile, :only => [:results,]
	def show
		id = params[:id]
		@quote = Quote.find(id)
	end
	def new
		@quote = Quote.new
	end
	def results
		id = params[:id]
		@quote = Quote.find(params[:id])
		@rates = @quote.get_rates()
		render "results"
	end
	def create
		@quote = Quote.new(params[:quote])
		if @quote.valid?
			## Redirect.
			@quote.save
			redirect_to action: 'results', quote_id: @quote.id
		else
			render "new"
		end
	end
	def index
		@quote = Quote.new
		render "new"
	end
end