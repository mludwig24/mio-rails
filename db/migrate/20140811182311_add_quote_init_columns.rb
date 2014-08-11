class AddQuoteInitColumns < ActiveRecord::Migration
	def change
		change_table :quotes do |t|
			t.date :enter_date
			t.date :leave_date
			t.integer :vehicle_type
			t.integer :year
			t.integer :make_id
			t.integer :model_id
			t.integer :value
			t.integer :towing
			t.integer :liability_limit
			t.integer :fixed_deductibles
			t.integer :body_style
			t.integer :liability
			t.integer :extended_travel
			t.integer :beyond_freezone
			t.integer :under21
			t.integer :uscoll_sc
			t.integer :days_veh_in_mexico
			t.integer :visit_reason
			t.string :other_model
		end
	end
end
