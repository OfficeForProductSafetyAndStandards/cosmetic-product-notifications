class UserSource < Source
  belongs_to_active_hash :user, inverse_of: :user_source

  def show
    "Created by #{user&.email || "anonymous"}"
  end
end
