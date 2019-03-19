class HelpController < ApplicationController
  skip_before_action :authenticate_user!, :authorize_user

  def terms_and_conditions; end

  def privacy_policy; end

  def about; end
end
