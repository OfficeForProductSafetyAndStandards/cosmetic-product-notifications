class BackfillLegacyRole < ActiveRecord::Migration[7.1]
  disable_ddl_transaction! # Ensures the migration doesn't lock the table

  def up
    User.unscoped.in_batches do |batch|
      batch.update_all("legacy_role = role")
    end
  end

  def down
    User.unscoped.in_batches do |batch|
      batch.update_all("role = legacy_role")
    end
  end
end
