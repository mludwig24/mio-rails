class AddMakeLabelToQuote < ActiveRecord::Migration
  def change
    add_column :quotes, :make_label, :string
    add_column :quotes, :model_label, :string
  end
end
