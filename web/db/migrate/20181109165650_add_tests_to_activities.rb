class AddTestsToActivities < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :activities, :test, index: false, foreign_key: true
    add_index :activities, :test_id, algorithm: :concurrently
  end
end
