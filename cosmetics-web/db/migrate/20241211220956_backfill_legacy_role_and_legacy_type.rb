class BackfillLegacyRoleAndLegacyType < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # update legacy_role with role and legacy_type with snake_case type
    User.unscoped.in_batches do |batch|
      batch.each do |user|
        legacy_type = user.type&.underscore # Proper snake_case conversion
        user.update_columns(legacy_role: user.role, legacy_type: legacy_type)
      end
    end
  end

  def down
    # Revert legacy_role to role and legacy_type to type if needed
    User.unscoped.in_batches do |batch|
      batch.each do |user|
        original_type = user.legacy_type&.camelize
        user.update_columns(role: user.legacy_role, type: original_type)
      end
    end
  end
end
