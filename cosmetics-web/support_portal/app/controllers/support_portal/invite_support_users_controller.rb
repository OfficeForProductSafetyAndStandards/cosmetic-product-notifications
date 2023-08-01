module SupportPortal
  class InviteSupportUsersController < ApplicationController
    def new
      @invite_support_user_form = InviteSupportUserForm.new
    end

    def create
      @invite_support_user_form = InviteSupportUserForm.new(support_user_params)

      if @invite_support_user_form.valid?
        InviteSupportUser.call(support_user_params)

        redirect_to(new_invite_support_user_path,
                    notice: "Invitation sent to #{@invite_support_user_form.name} at #{@invite_support_user_form.email}")
      else
        render :new
      end
    end

  private

    def support_user_params
      params.require(:invite_support_user_form).permit(:name, :email)
    end
  end
end
