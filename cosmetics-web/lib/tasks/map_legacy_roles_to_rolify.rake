namespace :map_legacy_roles_to_rolify do
  desc "Migrate legacy roles and types to Rolify"
  task migrate: :environment do
    Rails.logger.info "Starting role migration..."

    User.where(legacy_type_migrated: false).or(User.where(legacy_role_migrated: false)).find_each(batch_size: 500) do |user|
      unless user.legacy_type_migrated
        case user.legacy_type
        when "submit_user"
          user.add_role(:submit_user)
        when "search_user"
          user.add_role(:search_user)
        when "support_user"
          user.add_role(:support_user)
        end

        user.update!(legacy_type_migrated: true)
        Rails.logger.info "Migrated legacy_type for User #{user.id}: #{user.legacy_type}"
      end

      if !user.legacy_role_migrated && user.legacy_role.present?
        user.add_role(user.legacy_role.to_sym)
        user.update!(legacy_role_migrated: true)
        Rails.logger.info "Migrated legacy_role for User #{user.id}: #{user.legacy_role}"
      end
    rescue StandardError => e
      Rails.logger.error "Failed to process User #{user.id}: #{e.message}"
    end

    Rails.logger.info "Role migration completed."
  end
end
