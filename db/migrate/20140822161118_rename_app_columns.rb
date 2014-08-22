class RenameAppColumns < ActiveRecord::Migration
  def change
  	rename_column :apps, :pu_license_plate, :license_plate
  	rename_column :apps, :pu_license_state, :license_plate_state
  end
end
