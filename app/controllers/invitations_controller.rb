class InvitationsController < Devise::InvitationsController
  before_action :authenticate_user!, only: %i[new create]

  def new
    authorize User, :invite?
    super
  end

  def create
    authorize User, :invite?
    super
  end

  def after_invite_path_for(_resource)
    users_path
  end
end
