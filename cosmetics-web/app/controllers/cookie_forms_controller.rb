class CookieFormsController < PubliclyAccessibleController
  skip_before_action :require_secondary_authentication

  def create
    first_time = analytics_cookies_not_set?

    set_analytics_cookies(CookieForm.new(cookie_form_params).accept_analytics_cookies)
    if first_time
      redirect_back(fallback_location: root_path, cookies_banner_confirmation: true)
    else
      redirect_back(fallback_location: root_path, cookies_updated_successfully: true)
    end
  end

private

  def cookie_form_params
    params.fetch(:cookie_form, {}).permit(:accept_analytics_cookies)
  end
end
