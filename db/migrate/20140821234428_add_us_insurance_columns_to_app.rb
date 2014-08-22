class AddUsInsuranceColumnsToApp < ActiveRecord::Migration
  def change
    add_column :apps, :us_insurance_policy, :string
    add_column :apps, :us_insurance_expiration, :date
  end
end
