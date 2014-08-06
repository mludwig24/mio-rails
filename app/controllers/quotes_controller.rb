class QuotesController < ApplicationController
	def show
		id = params[:id]
		@quote = Quote.find(id)
	end
	def new
		@quote = Quote.new
	end
	def results
		if !session.has_key?("quote")
			return redirect_to action: "create"
		end
		@quote = session["quote"]
		@rates = @quote.get_rates()
		render "results"
	end
	def create
		@quote = Quote.new(params['quote'])
		if @quote.valid?
			## Redirect.
			session["quote"] = @quote
			redirect_to action: 'results'
		else
			render "new"
		end
	end
	def index
		@quote = Quote.new
		render "new"
	end
end