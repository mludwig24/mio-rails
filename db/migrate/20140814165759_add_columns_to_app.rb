class AddColumnsToApp < ActiveRecord::Migration
  def change
    add_column :apps, :type, :string
    add_column :apps, :first_name, :string
    add_column :apps, :last_name, :string
    add_column :apps, :address, :string
    add_column :apps, :city, :string
    add_column :apps, :state, :string
    add_column :apps, :zip, :string
    add_column :apps, :phone, :string
    add_column :apps, :email, :string
    add_column :apps, :license_number, :string
    add_column :apps, :license_state, :string
    add_column :apps, :vin, :string
    add_column :apps, :registration, :string
    add_column :apps, :us_insurance_company, :string
    add_column :apps, :ownership, :string
  end
end
