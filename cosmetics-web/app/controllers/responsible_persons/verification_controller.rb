class ResponsiblePersons::VerificationController < ApplicationController
  def show
    email_verification_key = EmailVerificationKey.verify_key_for_responsible_person(
      params[:responsible_person_id], 
      params[:key])

    email_verification_key.responsible_person.update(is_email_verified: true)
    redirect_to responsible_person_path(email_verification_key.responsible_person)
  end
end
