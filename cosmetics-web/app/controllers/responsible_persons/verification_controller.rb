class ResponsiblePersons::VerificationController < ApplicationController
  before_action :set_responsible_person, only: %i[index show resend_email]
  before_action :set_contact_person, only: %i[index show resend_email]
  skip_before_action :create_or_join_responsible_person

  def show
    email_verification_key = EmailVerificationKey.verify_key_for_responsible_person(
      @responsible_person,
      params[:key]
)

    unless email_verification_key.is_expired?
      email_verification_key.responsible_person.update(is_email_verified: true)
      Rails.logger.info "Responsible person email verified"
      return redirect_to responsible_person_path(email_verification_key.responsible_person)
    end
  end

  def index; end

  def resend_email
    EmailVerificationKey.where(responsible_person: @responsible_person).delete_all
    NotifyMailer.send_responsible_person_verification_email(
      @responsible_person.id,
      @contact_person.email_address,
      @contact_person.name,
      @responsible_person.name,
      User.current.name
).deliver_later

    redirect_to responsible_person_email_verification_keys_path(@responsible_person)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end

  def set_contact_person
    @contact_person = @responsible_person.contact_persons.first
  end
end
