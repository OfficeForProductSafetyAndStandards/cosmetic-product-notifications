class AddDeactivatedAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :deactivated_at, :datetime, precision: nil
  end
end
