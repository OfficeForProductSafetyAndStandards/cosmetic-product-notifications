class UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @users = search_for_users
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
    Role.all.each do |role|
      if new_roles.include? role.name
        @user.add_role role.name unless @user.has_role? role.name
      elsif @user.has_role? role.name
        @user.remove_role role.name
      end
    end
  end


  def search_for_users
    if params[:q].blank?
      User.paginate(page: params[:page], per_page: 20)
    else
      User.search(params[:q]).paginate(page: params[:page], per_page: 20).records
    end
  end
end
