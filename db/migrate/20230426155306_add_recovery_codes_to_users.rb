class AddRecoveryCodesToUsers < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :users, bulk: true do |t|
        t.integer :last_recovery_code_at
        t.datetime :secondary_authentication_recovery_codes_generated_at, precision: nil
        t.string :secondary_authentication_recovery_codes, array: true, default: []
        t.string :secondary_authentication_recovery_codes_used, array: true, default: []
      end
    end
  end
end
