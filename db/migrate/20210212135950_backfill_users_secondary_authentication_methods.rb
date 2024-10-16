class BackfillUsersSecondaryAuthenticationMethods < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    User.unscoped.where(account_security_completed: true).in_batches do |relation|
      relation.update_all secondary_authentication_methods: %w[sms]
      sleep(0.01) # throttle
    end
  end
end
