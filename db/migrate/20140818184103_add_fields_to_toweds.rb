class AddFieldsToToweds < ActiveRecord::Migration
  def change
    add_column :toweds, :make, :string
    add_column :toweds, :model, :string
    add_column :toweds, :license_plate, :string
    add_column :toweds, :license_plate_state, :string
    add_column :toweds, :vin, :string
  end
end
