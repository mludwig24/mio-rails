class ChangeExtendedTravelOnQuote < ActiveRecord::Migration
  def change
  	change_column :quotes, :extended_travel, :integer, :default => 1
  end
end
