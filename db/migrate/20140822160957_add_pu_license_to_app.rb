class AddPuLicenseToApp < ActiveRecord::Migration
  def change
    add_column :apps, :pu_license_plate, :string
    add_column :apps, :pu_license_state, :string
  end
end
