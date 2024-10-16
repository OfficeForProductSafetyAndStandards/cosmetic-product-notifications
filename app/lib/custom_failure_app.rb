class CustomFailureApp < Devise::FailureApp
  def scope_url
    # Customise the redirect URL that Devise uses
    # to redirect unauthenticated users to the sign in
    # page so it uses the correct domain. The default
    # URL options are initialized on startup and therefore
    # cannot be customised on a per-domain basis.
    url = super
    current_host = case request.host
                   when ENV["SEARCH_HOST"]
                     ENV["SEARCH_HOST"]
                   when ENV["SUPPORT_HOST"]
                     ENV["SUPPORT_HOST"]
                   else
                     ENV["SUBMIT_HOST"]
                   end
    url.sub(Rails.configuration.action_controller.default_url_options[:host], current_host)
  end
end
