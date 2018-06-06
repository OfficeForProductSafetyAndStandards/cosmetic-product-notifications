class UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @users = User.all
    authorize User
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    assign_roles params["user"]["_roles"] ||= []
    redirect_to users_path, notice: "User updated."
  end

  def destroy
    user = User.find(params[:id])
    authorize user
    user.destroy
    redirect_to users_path, notice: "User deleted."
  end

  private

  def assign_roles(new_roles)
    User.available_role_names.each do |role|
      if new_roles.include? role
        @user.add_role role unless @user.has_role? role
      elsif @user.has_role? role
        @user.remove_role role
      end
    end
  end
end
