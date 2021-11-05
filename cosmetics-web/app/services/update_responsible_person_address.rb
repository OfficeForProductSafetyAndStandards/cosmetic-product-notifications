class UpdateResponsiblePersonAddress
  include Interactor

  delegate :responsible_person, :user, :address, :original_address, to: :context

  def call
    context.fail!(error: "No responsible person provided") unless responsible_person
    context.fail!(error: "No user provided") unless user
    context.fail!(error: "No address provided") unless address
    context.fail!(error: "User does not belong to responsible person") unless user_belongs_to_responsible_person?
    context.fail!(error: "Address contains unknown fields") unless valid_address_fields?

    context.original_address = responsible_person.address_lines.join(", ")
    context.fail!(error: "Address is invalid") unless responsible_person.update(address)

    if responsible_person.saved_changes?
      send_confirmation_email
      send_alert_emails
    end
  end

private

  def user_belongs_to_responsible_person?
    responsible_person.users.include? user
  end

  def valid_address_fields?
    address.symbolize_keys.keys.all? { |field| field.in? ResponsiblePerson::ADDRESS_FIELDS }
  end

  def send_confirmation_email
    SubmitNotifyMailer.send_responsible_person_address_change_confirmation_email(
      responsible_person, user, original_address
    ).deliver_later
  end

  def send_alert_emails
    other_rp_members.each do |member|
      SubmitNotifyMailer.send_responsible_person_address_change_alert_email(
        responsible_person, member, user.name, original_address
      ).deliver_later
    end
  end

  def other_rp_members
    responsible_person.users.where.not(id: user.id)
  end
end
