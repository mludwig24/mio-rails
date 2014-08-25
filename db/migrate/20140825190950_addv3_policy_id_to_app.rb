class Addv3PolicyIdToApp < ActiveRecord::Migration
  def change
  	add_column :apps, :v3_policy_id, :string
  end
end
