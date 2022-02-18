class UpdateResponsiblePersonDetails
  include Interactor

  delegate :responsible_person, :user, :details, :original_address, to: :context

  def call
    context.fail!(error: "No Responsible Person provided") unless responsible_person
    context.fail!(error: "No user provided") unless user
    context.fail!(error: "No details provided") unless details
    context.fail!(error: "User does not belong to Responsible Person") unless user_belongs_to_responsible_person?
    context.fail!(error: "Details contain invalid attributes") unless valid_details?

    context.previous_address = previous_address

    ActiveRecord::Base.transaction do
      responsible_person.update!(details)
      if address_changed?
        previous_address.save!
        send_confirmation_email
        send_alert_emails
        context.changed = true
      elsif responsible_person.saved_changes?
        context.changed = true
      else
        context.changed = false
      end
    end
  rescue ActiveRecord::RecordInvalid
    context.fail!(error: "Address is invalid")
  end

private

  def user_belongs_to_responsible_person?
    responsible_person.users.include? user
  end

  def valid_details?
    allowed_fields = ResponsiblePerson::ADDRESS_FIELDS + [:account_type]
    details.symbolize_keys.keys.all? { |field| field.in? allowed_fields }
  end

  def address_changed?
    return false unless responsible_person.saved_changes?

    previous_address.line_1 != responsible_person.address_line_1 ||
      previous_address.line_2      != responsible_person.address_line_2 ||
      previous_address.city        != responsible_person.city ||
      previous_address.postal_code != responsible_person.postal_code ||
      previous_address.county      != responsible_person.county
  end

  def send_confirmation_email
    SubmitNotifyMailer.send_responsible_person_address_change_confirmation_email(
      responsible_person, user, previous_address
    ).deliver_later
  end

  def send_alert_emails
    other_rp_members.each do |member|
      SubmitNotifyMailer.send_responsible_person_address_change_alert_email(
        responsible_person, member, user, previous_address
      ).deliver_later
    end
  end

  def other_rp_members
    responsible_person.users.where.not(id: user.id)
  end

  def previous_address
    @previous_address ||= ResponsiblePersonAddressLog.new(
      responsible_person: responsible_person,
      line_1: responsible_person.address_line_1,
      line_2: responsible_person.address_line_2,
      city: responsible_person.city,
      county: responsible_person.county,
      postal_code: responsible_person.postal_code,
    )
  end
end
