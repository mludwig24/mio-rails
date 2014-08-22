class AddFinanceFieldsToApp < ActiveRecord::Migration
  def change
    add_column :apps, :finance_company, :string
    add_column :apps, :finance_account, :string
    add_column :apps, :finance_address, :string
    add_column :apps, :finance_city, :string
    add_column :apps, :finance_state, :string
    add_column :apps, :finance_zip, :string
  end
end
