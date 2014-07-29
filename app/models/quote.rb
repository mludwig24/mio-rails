## Re-open the date class to help with the date_select form element.
class Date
	def self.new_from_date_select(hash, key)
		Date.new(hash["#{key}(1i)"].to_i,
			hash["#{key}(2i)"].to_i,
			hash["#{key}(3i)"].to_i)
	rescue
		return nil
	end
	def self.new_from_date_select!(hash, key)
		date = self.new_from_date_select(hash, key)
		if hash && hash.has_key?("#{key}(1i)")
			hash.delete("#{key}(1i)")
			hash.delete("#{key}(2i)")
			hash.delete("#{key}(3i)")
		end
		return date
	end
end

class Quote
	include ActiveModel::Model
	def initialize(data=nil)
		@enter_date = Date.new_from_date_select!(data, "enter_date")
		@leave_date = Date.new_from_date_select!(data, "leave_date")
		super
	end

	attr_accessor :enter_date, :leave_date, :username,
		:api_key, :agtdst, :office_code, :power_unit
	## Powerunit.
	attr_accessor :vehicle_type, :year, :make_id,
		:model_id, :value, :towing, :liability_limit,
		:fixed_deductibles, :body_style, :other_model
	validates :fixed_deductibles, :presence => true,
		:inclusion => {:in => ["0", "1"]}
	validates :liability_limit, :presence => true,
		:inclusion => {:in => Proc.new { Quote.valid_liability_limits().to_s }}
	## Underwriting.
	attr_accessor :beyond_freezone, :under21, :uscoll_sc,
		:days_veh_in_mexico, :visit_reason
	validates :under21, :presence => true,
		:inclusion => {:in => ["0", "1"]}
	validates :beyond_freezone, :presence => true,
		:inclusion => {:in => ["0", "1"]}
	validates :uscoll_sc, :presence => true,
		:inclusion => {:in => ["0", "1"]}
	validates :days_veh_in_mexico, :presence => true,
		:inclusion => {:in => Proc.new { Quote.valid_days_veh_in_mexico().to_s }}
	validates :visit_reason, :presence => true,
		:inclusion => {:in => Proc.new { Quote.valid_visit_reasons().to_s }}
	## Limits.
	attr_accessor :liability, :extended_travel
	validates_presence_of :enter_date, :leave_date,
		:vehicle_type, :year, :make_id, :value
	validates :model_id, presence: true, 
		allow_blank: false,
		unless: "other_model.present?"
	validates :other_model, presence: true,
		allow_blank: false,
		unless: "model_id.present?"
	validates :leave_date, :date => {
		:after_or_equal_to => :enter_date,
		:before => Proc.new { Date.today + 366 }, ## 1 year days is too far.
	}
	validates :enter_date, :date => {
		:after_or_equal_to => Proc.new { Date.today },
		:before => Proc.new { Date.today + 90 }, ## 90 days is too far.
	}
	validates :year, numericality: { only_integer: true },
		:inclusion => {:in => Proc.new { Quote.valid_years().to_s } }

	def self.valid_years
		years = ((Date.today.year - 35)..Date.today.year).to_a
		if Date.today.month >= 4
			years << Date.today.year + 1
		end
		return years
	end
	def valid_years
		return self.class.valid_years()
	end
	def valid_values
		values = [0]
		(3..400).each do |x|
			values << x * 1000
		end
		return values
	end
	def self.valid_liability_limits
		[50000, 100000, 300000, 500000]
	end
	def valid_liability_limits
		return self.class.valid_liability_limits()
	end
	def self.valid_visit_reasons
		[
			1, # Driving to Vacation Destination/Tourist Visa
			2, # Visiting Friends or Family
			3, # Business/Work/School/Frequent Commuter
			4, # Temporary Mexico Resident Visa Holder
			5,  # Permanent Mexico Resident Visa Holder
		]
	end
	def valid_visit_reasons
		return self.class.valid_visit_reasons()
	end
	def self.valid_days_veh_in_mexico
		[
			1, # Less than 30
			2, # Between 31 and 90
			3, # Between 90 and 180
			4, # More than 180
		]
	end
	def valid_days_veh_in_mexico
		return self.class.valid_days_veh_in_mexico()
	end
end
