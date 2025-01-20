module LegacyData
  def self.remove_plus_part(email)
    return email unless email

    local, domain = email.split("@", 2)
    return email unless domain

    local = local.split("+").first
    [local, domain].join("@")
  end
end

namespace :legacy_data do
  desc "Populate legacy columns on Users and clean up emails"
  task populate: :environment do
    User.unscoped.in_batches do |batch|
      batch.each do |user|
        corrected_email = LegacyData.remove_plus_part(user.email)
        user.update_columns(
          legacy_role: user.role,
          legacy_type: user.type&.underscore,
          corrected_email: corrected_email,
        )
      end
    end

    puts "Populated legacy columns and updated emails for all users."
  end
end
