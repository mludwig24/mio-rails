class CreateDrivers < ActiveRecord::Migration
  def change
    create_table :drivers do |t|
      t.string :first_name
      t.string :last_name
      t.string :token
      t.references :app_id, index: true

      t.timestamps
    end
  end
end
