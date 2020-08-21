class UsersController < ApplicationController
  skip_before_action :authenticate_user!
  # skip_before_action :has_accepted_declaration
  # skip_before_action :has_viewed_introduction
  # skip_before_action :require_secondary_authentication

  def complete_registration
    @user = User.find(params[:id])

    return render :accept_invitation_signed_in_as_another_user if user_signed_in? && !signed_in_as?(@user)

    # Some users will bookmark the invitation URL received on the email and may re-use
    # this even once their account has been created. Hence redirecting them to the root page.
    return redirect_to(root_path) if signed_in_as?(@user) || @user.has_completed_registration?
    return render(:expired_invitation) if @user.invitation_expired?
    return (render "errors/not_found", status: :not_found) if !params[:invitation] || (@user.invitation_token != params[:invitation])

    # Reset name and mobile number in case they've been remembered
    # from a previous registration that was abandoned before the mobile number
    # was verified via two-factor authentication.
    @user.name = ""
    @user.mobile_number = ""

    render :complete_registration
  end

  def sign_out_before_accepting_invitation
    sign_out
    redirect_to complete_registration_user_path(params[:id], invitation: params[:invitation])
  end

  def update
    @user = SearchUser.find(params[:id])
    return render("errors/forbidden", status: :forbidden) if params[:invitation] != @user.invitation_token

    @user.assign_attributes(new_user_attributes)

    if @user.save(context: :registration_completion)
      sign_in :search_user, @user
      redirect_to root_path
    else
      render :complete_registration
    end
  end

private

  def new_user_attributes
    params.require(user_params_key).permit(:name, :password, :mobile_number)
  end

  def signed_in_as?(user)
    current_user == user
  end
end
