class UserSource < Source
  belongs_to :user, foreign_key: "user_id", inverse_of: :user_source

  def show
    "Created by " + (user.present? ? user.email : "anonymous")
  end

  def name
    user.present? ? user.email : "anonymous"
  end
end
