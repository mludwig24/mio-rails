class Towed < ActiveRecord::Base
	belongs_to :quote

	def self.valid_us_states ## For validation farther down.
		AppsController.helpers.us_states.map{|x| x[1]} # ["State", "State Code"]
	end
	def valid_us_states; self.class.us_states end
	
	validates_presence_of :type_id, :type_label, :year, :value
	validates_numericality_of :type_id, :year, :value
	attr_accessor :app_mode
	validates_presence_of :make, :model, :vin, :license_plate,
		:license_plate_state,
		:if => Proc.new { |towed| towed.app_mode }
	validates :license_plate_state, :inclusion => valid_us_states,
		:if => Proc.new { |towed| towed.app_mode }
end
