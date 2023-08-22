module SupportPortal
  class SupportUsersController < ApplicationController
    before_action :set_user, except: %i[index]
    before_action :redirect_if_disallowed_user, only: %i[remove deactivate]

    def index
      @users = SupportUser.where.not(id: current_user.id).where(deactivated_at: nil)
    end

    # GET /:id/remove
    def remove; end

    # PATCH/PUT /:id/deactivate
    def deactivate
      if @user.update(deactivated_at: Time.zone.now)
        @user.reset_secondary_authentication!
        redirect_to support_users_path, notice: "Team member #{@user.name} removed from OSU portal"
      else
        render :deactivate_account
      end
    end

  private

    def set_user
      @user = SupportUser.find(params[:id])
    end

    def redirect_if_disallowed_user
      (@user.is_a?(::SupportUser) && !@user.deactivated?) || @user == current_user
    end
  end
end
