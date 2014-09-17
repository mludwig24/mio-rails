module ApplicationHelper
end

# Re-opening string to create phone numbers.
class String
	def slug
		self.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
	end
end