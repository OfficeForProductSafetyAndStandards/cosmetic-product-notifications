class UserSource < Source
  belongs_to_active_hash :user, inverse_of: :user_source

  def show
    user.present? ? user.display_name : "anonymous"
  end

  def user_has_gdpr_access?(user_in_question: User.current)
    user_in_question.organisation == user&.organisation
  end
end
