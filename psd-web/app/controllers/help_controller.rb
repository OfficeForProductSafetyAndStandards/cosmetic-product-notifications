class HelpController < ApplicationController
  skip_before_action :authenticate_user!, :authorize_user, :has_accepted_declaration

  def terms_and_conditions; end

  def privacy_notice; end

  def about; end

  def hide_nav?
    !(User.current.present? && User.current.has_accepted_declaration)
  end
end
