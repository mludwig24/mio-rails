class AddTowedRefToQuotes < ActiveRecord::Migration
  def change
    add_reference :toweds, :quote, index: true
  end
end
