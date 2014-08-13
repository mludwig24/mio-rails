class RenameTowedTypeToTypeId < ActiveRecord::Migration
  def change
  	rename_column :toweds, :type, :type_id
  end
end
