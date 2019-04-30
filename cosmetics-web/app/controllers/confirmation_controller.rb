class ConfirmationController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authorize_user!
  skip_before_action :create_or_join_responsible_person
  skip_before_action :has_accepted_declaration

  def show
    email_verification_key = EmailVerificationKey.find_by!(key: params[:key])
    if email_verification_key.is_expired?
      redirect_to link_expired_confirmation_index_path
    else
      email_verification_key.responsible_person.update(is_email_verified: true)
    end
  end

  def linked_expired; end
end
