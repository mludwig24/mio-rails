class Towed < ActiveRecord::Base
	belongs_to :quote
	validates_presence_of :type_id, :year, :value
	validates_numericality_of :type_id, :year, :value
end
