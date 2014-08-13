class App < ActiveRecord::Base
	belongs_to :quote
	before_create :generate_token

	protected

	def generate_token
		self.token = loop do
			random_token = SecureRandom.urlsafe_base64(8, false).downcase
			break random_token unless Quote.exists?(token: random_token)
		end
	end
end
