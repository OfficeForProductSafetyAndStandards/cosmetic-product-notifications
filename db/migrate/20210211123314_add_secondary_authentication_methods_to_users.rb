class AddSecondaryAuthenticationMethodsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :secondary_authentication_methods, :string, array: true
  end
end
