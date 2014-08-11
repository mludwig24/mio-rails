class AddTokenToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :token, :string
    add_index :quotes, :token, :unique => true
  end
end
