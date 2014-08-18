class RenameDriversAppIdIdtoAppId < ActiveRecord::Migration
  def change
  	rename_column :drivers, :app_id_id, :app_id
  end
end
