class SearchApplicationController < ApplicationController
  before_action :allow_only_search_domain
  before_action :has_accepted_declaration

private

  def allow_only_search_domain
    raise "Not a search domain" unless search_domain?
  end

  def authorize_user!
    redirect_to invalid_account_path if current_user && !current_user.is_a?(SearchUser)
  end
end
