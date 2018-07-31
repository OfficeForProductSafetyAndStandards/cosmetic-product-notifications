class InvitationsController
  before_action :authenticate_user!, only: %i[new create]

  def new
    authorize User, :invite?
  end

  def create
    authorize User, :invite?
  end

  def after_invite_path_for(_resource)
    users_path
  end
end
