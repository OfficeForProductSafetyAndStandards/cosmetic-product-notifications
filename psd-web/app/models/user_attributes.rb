class UserAttributes < ApplicationRecord
  belongs_to_active_hash :user

  def has_viewed_introduction!
    update has_viewed_introduction: true
  end

  def has_accepted_declaration!
    update has_accepted_declaration: true
  end

  def has_been_sent_welcome_email!
    update has_been_sent_welcome_email: true
  end
end
