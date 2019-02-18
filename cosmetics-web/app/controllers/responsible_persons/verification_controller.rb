class ResponsiblePersons::VerificationController < ApplicationController
  before_action :set_responsible_person, only: %i[index resend_email]
  skip_before_action :create_or_join_responsible_person, only: %i[index resend_email]
  def show
    email_verification_key = EmailVerificationKey.verify_key_for_responsible_person(
      params[:responsible_person_id], 
      params[:key])

    email_verification_key.responsible_person.update(is_email_verified: true)
    redirect_to responsible_person_path(email_verification_key.responsible_person)
  end

  def index; end

  def resend_email
    key = @responsible_person.email_verification_keys.create

    NotifyMailer.send_responsible_person_verification_email(
      @responsible_person.email_address,
      current_user.full_name,
      responsible_person_email_verification_key_path(@responsible_person, key)
    ).deliver_later

    redirect_to responsible_person_email_verification_keys_path(@responsible_person)
  end

  private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end
end
