class CookieFormsController < PubliclyAccessibleController
  skip_before_action :require_secondary_authentication

  def create
    session[:accept_analytics_cookies] = CookieForm.new(cookie_form_params).accept_analytics_cookies
    redirect_back(fallback_location: root_path)
  end

private

  def cookie_form_params
    params.fetch(:cookie_form, {}).permit(:accept_analytics_cookies)
  end
end
