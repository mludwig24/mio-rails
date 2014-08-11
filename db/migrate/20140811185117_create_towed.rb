class CreateTowed < ActiveRecord::Migration
  def change
    create_table :toweds do |t|
    	t.integer :type
    	t.integer :year
    	t.integer :value
    end
  end
end
