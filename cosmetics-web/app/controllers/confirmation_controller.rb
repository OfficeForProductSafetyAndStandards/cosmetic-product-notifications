class ConfirmationController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authorize_user!
  skip_before_action :create_or_join_responsible_person

  def contact_person
    email_verification_key = EmailVerificationKey.find_by(key: params[:key])
    return redirect_to "/404" if email_verification_key.blank?
    return redirect_to link_expired_confirmation_path if email_verification_key.is_expired?
  end

  def linked_expired; end
end
