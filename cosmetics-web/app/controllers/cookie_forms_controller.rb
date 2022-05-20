class CookieFormsController < PubliclyAccessibleController
  skip_before_action :require_secondary_authentication

  def create
    form = CookieForm.new(cookie_form_params.merge(session: session))
    form.save

    redirect_back(fallback_location: root_path)
  end

private

  def cookie_form_params
    params.fetch(:cookie_form, {}).permit(:accept_analytics_cookies)
  end
end
