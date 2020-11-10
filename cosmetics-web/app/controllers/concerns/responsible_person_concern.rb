module ResponsiblePersonConcern
  extend ActiveSupport::Concern

  def create_or_join_responsible_person
    return unless fully_signed_in_submit_user?

    responsible_person = current_responsible_person

    if responsible_person.blank?
      if current_user.responsible_persons.present?
        redirect_to select_responsible_persons_path
      elsif pending_invitations.any?
        redirect_to account_path(:pending_invitations)
      else
        redirect_to account_path(:overview)
      end
    elsif responsible_person.contact_persons.empty?
      redirect_to new_responsible_person_contact_person_path(responsible_person)
    end
  end

  def current_responsible_person
    rp = current_user.responsible_persons.find_by id: session[:current_responsible_person_id]
    if rp.nil? && current_user.responsible_persons.count == 1
      current_user.responsible_persons.first
    else
      rp
    end
  end

  def set_current_responsible_person(responsible_person)
    session[:current_responsible_person_id] = responsible_person.id
  end

  def validate_responsible_person
    return if @responsible_person.nil?

    if @responsible_person != current_responsible_person
      redirect_to select_responsible_persons_path
    end
  end

private

  def fully_signed_in_submit_user?
    if Rails.configuration.secondary_authentication_enabled
      user_signed_in? && secondary_authentication_present? && current_user.mobile_number_verified?
    else
      user_signed_in?
    end
  end

  def pending_responsible_persons_invitations_text
    @pending_responsible_persons_invitations_text ||= PendingResponsiblePersonInvitationsPresenter
      .new(pending_invitations)
      .responsible_persons_invitations_text
  end

  def pending_invitations
    @pending_invitations ||= PendingResponsiblePersonUser
      .where(email_address: current_user.email)
      .includes(:responsible_person, :inviting_user)
      .order(created_at: :desc)
  end
end
