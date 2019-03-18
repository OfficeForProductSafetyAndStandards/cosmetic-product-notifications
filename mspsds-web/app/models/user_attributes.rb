class UserAttributes < ApplicationRecord
  belongs_to_active_hash :user

  def has_viewed_introduction=(value)
    super value
    # For each setter in UserAttributes, we need to call save in addition to setting the attribute because otherwise
    # Rails reloads the object when we call User#user_attributes and this overwrites any changed we have made before
    # they are saved.
    save
  end
end
