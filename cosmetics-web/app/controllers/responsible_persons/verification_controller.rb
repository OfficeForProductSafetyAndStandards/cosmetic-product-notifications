class ResponsiblePersons::VerificationController < ApplicationController
  def show
    email_verification_key = EmailVerificationKey.find_by!(
      "responsible_person_id = ? AND key = ? AND expires_at >= ?", 
      params[:responsible_person_id], params[:key], DateTime.current
    )

    email_verification_key.responsible_person.update('is_email_verified' => true)
    redirect_to responsible_person_path(email_verification_key.responsible_person)
  end
end
