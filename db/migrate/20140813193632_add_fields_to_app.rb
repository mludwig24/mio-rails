class AddFieldsToApp < ActiveRecord::Migration
  def change
    add_column :apps, :tid, :string
    add_column :apps, :uid, :int
  end
end
