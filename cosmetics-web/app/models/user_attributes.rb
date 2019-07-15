class UserAttributes < ApplicationRecord
  belongs_to_active_hash :user

  def has_accepted_declaration?
    declaration_accepted_at.present?
  end

  def has_accepted_declaration!
    update declaration_accepted_at: Time.zone.now
  end
end
