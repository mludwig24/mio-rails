class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.timestamps
    end
    add_reference :apps, :quote, index: true
  end
end
