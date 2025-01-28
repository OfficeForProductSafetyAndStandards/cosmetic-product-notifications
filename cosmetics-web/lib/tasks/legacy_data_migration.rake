module LegacyData
  def self.remove_plus_part(email)
    return email unless email

    local, domain = email.split("@", 2)
    return email unless domain

    local = local.split("+").first
    [local, domain].join("@")
  end
end

namespace :legacy_data_migration do
  desc "Populate legacy columns, clean up emails, and migrate roles to Rolify"
  task migrate: :environment do
    Rails.logger.info "Starting legacy data population and role migration..."

    Rails.logger.info "Populating legacy columns and correcting emails..."
    User.unscoped.find_each(batch_size: 500) do |user|
      corrected_email = LegacyData.remove_plus_part(user.email)
      user.update_columns(
        legacy_role: user.role,
        legacy_type: user.type&.underscore,
        corrected_email: corrected_email,
      )
      Rails.logger.info "Updated User ID: #{user.id} - Legacy data populated."
    rescue StandardError => e
      Rails.logger.error "Failed to populate legacy data for User ID: #{user.id}: #{e.message}"
    end

    Rails.logger.info "Migrating roles to Rolify..."
    User.where(legacy_type_migrated: false)
        .or(User.where(legacy_role_migrated: false))
        .find_each(batch_size: 500) do |user|
      unless user.legacy_type_migrated
        case user.legacy_type
        when "submit_user"
          user.add_role(:submit_user)
        when "search_user"
          user.add_role(:search_user)
        when "support_user"
          user.add_role(:support_user)
        else
          Rails.logger.warn "User #{user.id} has an unknown or missing legacy_type: #{user.legacy_type}"
        end

        user.update_columns(legacy_type_migrated: true)
        Rails.logger.info "Migrated legacy_type for User #{user.id}: #{user.legacy_type}"
      end

      unless user.legacy_role_migrated
        if user.legacy_role.present?
          user.add_role(user.legacy_role.to_sym)
          Rails.logger.info "Migrated legacy_role for User #{user.id}: #{user.legacy_role}"
        else
          Rails.logger.info "User #{user.id} has no legacy_role; marking as migrated."
        end

        user.update_columns(legacy_role_migrated: true)
      end
    rescue StandardError => e
      Rails.logger.error "Failed to migrate roles for User ID: #{user.id}: #{e.message}"
    end

    Rails.logger.info "Legacy data population and role migration completed."
  end
end
