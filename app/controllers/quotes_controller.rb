class QuotesController < ApplicationController
	def show
		id = params[:id]
		@quote = Quote.find(id)
	end
	def new
		@quote = Quote.new
	end
	def create
		@quote = Quote.new(params['quote'])
		render "new"
	end
	def index
		@quote = Quote.new
		render "new"
	end
end
