class SupportApplicationController < ApplicationController
  before_action :allow_only_support_domain

private

  def allow_only_support_domain
    raise "Not a support domain" unless support_domain?
  end

  def authorize_user!
    redirect_to invalid_account_path if current_user && !current_user.is_a?(SupportUser)
  end
end
