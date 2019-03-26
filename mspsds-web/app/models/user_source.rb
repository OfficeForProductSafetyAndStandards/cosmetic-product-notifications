class UserSource < Source
  belongs_to_active_hash :user, inverse_of: :user_source

  def show
    user.present? ? user.display_name : "anonymous"
  end

  def user_has_gdpr_access?(user: User.current)
    user.organisation == self.user&.organisation
  end
end
