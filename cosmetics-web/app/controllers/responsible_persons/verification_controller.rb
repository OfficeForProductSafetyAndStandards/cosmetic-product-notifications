class ResponsiblePersons::VerificationController < ApplicationController
  before_action :set_responsible_person, only: %i[index resend_email]
  before_action :set_contact_person, only: %i[index resend_email]
  skip_before_action :create_or_join_responsible_person

  def index; end

  def resend_email
    EmailVerificationKey.where(contact_person: @contact_person).delete_all
    NotifyMailer.send_contact_person_verification_email(
      @contact_person.id,
      @contact_person.name,
      @contact_person.email_address,
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
