module SupportPortal
  class InviteSupportUsersController < ApplicationController
    def new
      @user = ::SupportUser.new
    end

    def create
      if valid_user?
        ::InviteSupportUser.call(support_user_params)
        redirect_to(new_invite_support_user_path, notice: "Invitation sent to #{support_user_params[:name]} at #{support_user_params[:email]}")
      else
        render :new
      end
    end

  private

    def support_user_params
      params.require(:support_user).permit(:name, :email)
    end

    def valid_user?
      return true unless SupportUser.where(email: support_user_params[:email]).where.not(deactivated_at: nil).empty?

      SupportUser.new(support_user_params.merge(skip_password_validation: true)).valid?
    end
  end
end
