class UsersController < ApplicationController
  after_action :verify_authorized

  def index
    @users = User.all
    authorize User
  end
end
