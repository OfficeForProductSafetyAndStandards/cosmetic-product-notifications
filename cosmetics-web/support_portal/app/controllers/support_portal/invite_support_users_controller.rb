module SupportPortal
  class InviteSupportUsersController < ApplicationController
    def new
      @user = ::SupportUser.new
    end

    def create
      @user = ::SupportUser.new(support_user_params.merge(skip_password_validation: true))

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
  end
end
