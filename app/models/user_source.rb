class UserSource < Source
  belongs_to :user, inverse_of: :user_source

  def show
    "Created by " + user.email
  end
end
