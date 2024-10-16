module SupportPortal
  class InviteSupportUsersController < ApplicationController
    before_action :set_user, only: :create

    def new
      @user = ::SupportUser.new
    end

    def create
      if @user.valid?
        ::InviteSupportUser.call(support_user_params)
        redirect_to(new_invite_support_user_path, notice: "Invitation sent to #{@user.name} at #{@user.email}")
      else
        render :new
      end
    end

  private

    def support_user_params
      params.require(:support_user).permit(:name, :email)
    end

    def set_user
      @user = SupportUser.where(email: support_user_params[:email]).where.not(deactivated_at: nil).first

      @user = SupportUser.new(support_user_params.merge(skip_password_validation: true)) if @user.nil?
    end
  end
end
