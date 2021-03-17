class SecondaryAuthenticationMethodController < ApplicationController
  skip_before_action :authenticate_user!,
                     :require_secondary_authentication,
                     :authorize_user!,
                     :set_cache_headers

  def new
    unless session[:secondary_authentication_user_id] && secondary_authentication_user
      return render("errors/forbidden", status: :forbidden)
    end

    @form = SecondaryAuthenticationMethodForm.new(
      mobile_number: secondary_authentication_user.mobile_number,
    )
  end

  def create
    if form.valid?
      session[:secondary_authentication_method] = form.authentication_method
      redirect_to new_secondary_authentication_path
    else
      render :new
    end
  end

private

  def form
    @form ||= SecondaryAuthenticationMethodForm.new(
      secondary_authentication_method_params.merge(mobile_number: secondary_authentication_user.mobile_number),
    )
  end

  def secondary_authentication_method_params
    params.permit(:authentication_method)
  end
end
