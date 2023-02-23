# UnusedCodeAlerting
# This model seems unused.
# There are 0 elements in production DB.
# Delete the model and the table from DB.
class UserAttributes < ApplicationRecord
  belongs_to_active_hash :user

  def has_accepted_declaration?
    UnusedCodeAlerting.alert
    declaration_accepted_at.present?
  end

  def has_accepted_declaration!
    UnusedCodeAlerting.alert
    update declaration_accepted_at: Time.zone.now
  end
end
