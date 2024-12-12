namespace :migrate_roles do
  desc "Migrate legacy roles and types to Rolify"
  task migrate: :environment do
    User.find_each do |user|
      # Assign legacy roles
      user.add_role(user.legacy_role.to_sym) if user.legacy_role.present?

      # Assign type-based roles
      case user.legacy_type
      when "submit_user"
        user.add_role(:submit_user)
      when "search_user"
        user.add_role(:search_user)
      when "support_user"
        user.add_role(:support_user)
      end

      Rails.logger.info "Processed User #{user.id} with roles: #{user.roles.pluck(:name)}"
    end
  end
end