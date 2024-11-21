namespace :migrate_roles do
  desc "Migrate legacy roles to Rolify"
  task migrate: :environment do
    User.find_each do |user|
      next if user.legacy_role.blank?

      user.add_role(user.legacy_role.to_sym)
      Rails.logger.info "Migrated role #{user.legacy_role} for User #{user.id}"
    end
  end
end
