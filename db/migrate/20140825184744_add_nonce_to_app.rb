class AddNonceToApp < ActiveRecord::Migration
  def change
    add_column :apps, :payment_method_nonce, :string
  end
end
