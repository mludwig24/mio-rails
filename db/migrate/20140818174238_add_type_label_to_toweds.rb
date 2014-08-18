class AddTypeLabelToToweds < ActiveRecord::Migration
  def change
  	add_column :toweds, :type_label, :string
  end
end
