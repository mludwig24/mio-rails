class AddApiQuoteIdToQuote < ActiveRecord::Migration
  def change
    add_column :quotes, :api_quote_id, :integer
  end
end
