class ResponsiblePersons::VerificationController < ApplicationController
  def show
    email_verification_key = EmailVerificationKey.find_by(
      responsible_person_id: params[:responsible_person_id],
        key: params[:key]
)

    if email_verification_key.nil? || email_verification_key.is_expired?
      redirect_to "/404"
    else
      redirect_to responsible_person_path(email_verification_key.responsible_person)
    end
  end
end
