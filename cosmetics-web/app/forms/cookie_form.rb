class CookieForm < Form
  attribute :accept_analytics_cookies, :boolean
  attribute :session

  def initialize(attributes = {})
    super

    if accept_analytics_cookies.nil? && session && !session[:accept_analytics_cookies].nil?
      self.accept_analytics_cookies = session[:accept_analytics_cookies]
    end
  end

  def save
    session[:accept_analytics_cookies] = accept_analytics_cookies
  end
end
