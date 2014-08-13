class AppController < ApplicationController
	before_action :get_app
	def personal
	end
	def show
	end
	def index
		redirect_to action: 'personal', token: @app.token
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
				@app.save()
			end
		end
		@quote = @app.quote
		if init_params.has_key?(:uid) || init_params.has_key?(:tid)
			@app.uid = init_params[:uid]
			@app.tid = init_params[:tid]
			@app.save()
		end
	end
	def app_params
		params.require(:app).permit(:uid, :tid)
	end
	def init_params
		params.permit(:uid, :tid)
	end
	def quote_token
		params.permit(:qid)
	end
end