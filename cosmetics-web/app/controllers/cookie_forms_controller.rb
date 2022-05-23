class CookieFormsController < PubliclyAccessibleController
  skip_before_action :require_secondary_authentication

  def create
    if params[:accept_analytics_cookies].present?
      session[:accept_analytics_cookies] = params[:accept_analytics_cookies]
    end

    redirect_back(fallback_location: root_path)
  end
end
