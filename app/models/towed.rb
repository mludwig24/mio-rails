class Towed < ActiveRecord::Base
	belongs_to :quote

	def self.valid_us_states ## For validation farther down.
		AppsController.helpers.us_states.map{|x| x[1]} # ["State", "State Code"]
	end
	def valid_us_states; self.class.us_states end
	
	validates_presence_of :type_id, :year, :value
	validates_presence_of :type_label,
		:if => Proc.new { |towed| towed.type_id != nil }
	validates_numericality_of :year, :value
	validates_numericality_of :type_id,
		:if => Proc.new { |towed| towed.type_id != nil }
	attr_accessor :app_mode
	validates_presence_of :make, :model, :vin, :license_plate,
		:if => Proc.new { |towed| towed.app_mode }
	validates :license_plate_state, :inclusion => valid_us_states,
		:if => Proc.new { |towed| towed.app_mode }
end
