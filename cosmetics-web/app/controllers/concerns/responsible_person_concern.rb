module ResponsiblePersonConcern
  extend ActiveSupport::Concern

  def create_or_join_responsible_person
    return unless current_user&.has_completed_registration?

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
    rp = find_responsible_person(session[:current_responsible_person_id])
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

  def set_current_responsible_person_from_previous
    if session[:previous_responsible_person_id].present?
      set_current_responsible_person(find_responsible_person(session[:previous_responsible_person_id]))
      session[:previous_responsible_person_id] = nil
    end
  end

  def set_previous_responsible_person
    if current_responsible_person
      session[:previous_responsible_person_id] = current_responsible_person&.id
    elsif current_user.responsible_persons.one?
      rp = current_user.responsible_persons.first
      session[:previous_responsible_person_id] = rp&.id
    end
  end

private

  def pending_invitations
    @pending_invitations ||= PendingResponsiblePersonUser
      .where(email_address: current_user.email)
      .includes(:responsible_person, :inviting_user)
      .order(created_at: :desc)
  end

  def find_responsible_person(id)
    current_user.responsible_persons.find_by id: id
  end
end
