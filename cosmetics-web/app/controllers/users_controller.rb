class UsersController < SearchApplicationController
  skip_before_action :authenticate_user!

  def complete_registration
    @user = User.find(params[:id])

    return render :accept_invitation_signed_in_as_another_user if user_signed_in? && !signed_in_as?(@user)

    # Some users will bookmark the invitation URL received on the email and may re-use
    # this even once their account has been created. Hence redirecting them to the root page.
    return redirect_to(root_path) if signed_in_as?(@user) || @user.has_completed_registration?
    return render(:expired_invitation) if @user.invitation_expired?
    return (render "errors/not_found", status: :not_found) if !params[:invitation] || (@user.invitation_token != params[:invitation])

    @account_security_form = Registration::AccountSecurityForm.new(user: @user)

    render :complete_registration
  end

  def sign_out_before_accepting_invitation
    sign_out
    redirect_to complete_registration_user_path(params[:id], invitation: params[:invitation])
  end

  def update
    @user = SearchUser.find(params[:id])
    return render("errors/forbidden", status: :forbidden) if params[:invitation] != @user.invitation_token

    if account_security_form.update!
      sign_in :search_user, @user
      # Sets 2FA cookie for users that have set authentication APP in the account security page.
      # If they have chosen the sms code authentication option we won't set the cookie until
      # they confirm their mobile number with the sms code at "Check your phone" page.
      if account_security_form.app_authentication_selected? && !account_security_form.sms_authentication_selected?
        set_secondary_authentication_cookie(Time.zone.now.to_i) if @user.last_totp_at
      end
      redirect_to root_path
    else
      render :complete_registration
    end
  end

private

  def signed_in_as?(user)
    current_user == user
  end

  def account_security_form
    @account_security_form ||=
      Registration::AccountSecurityForm.new(account_security_form_params.merge(user: @user))
  end

  def account_security_form_params
    params.require(:registration_account_security_form)
          .permit(:mobile_number,
                  :password,
                  :full_name,
                  :app_authentication_secret_key,
                  :app_authentication_code,
                  :sms_authentication,
                  :app_authentication)
  end
end
