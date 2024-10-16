class AddUniqueSessionIdToUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :users, :unique_session_id, :string
    end
  end
end
