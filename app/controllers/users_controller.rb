class UsersController < ApplicationController
  include UsersHelper

  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @users = search_for_users(20)
    authorize User
  end
end
