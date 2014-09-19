class AddExtendedTravelToQuote < ActiveRecord::Migration
  def change
    change_column :quotes, :extended_travel, :bool, :default => true
  end
end
