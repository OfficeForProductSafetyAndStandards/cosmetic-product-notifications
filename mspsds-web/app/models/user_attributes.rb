class UserAttributes < ApplicationRecord
  belongs_to_active_hash :user

  def has_viewed_introduction!
    update has_viewed_introduction: true
  end
end
