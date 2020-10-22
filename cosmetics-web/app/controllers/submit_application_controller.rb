class SubmitApplicationController < ApplicationController
  before_action :allow_only_submit_domain
  before_action :try_to_finish_account_setup
  before_action :has_accepted_declaration
  before_action :create_or_join_responsible_person

  def current_responsible_person
    current_user.current_responsible_person
  end
  helper_method :current_responsible_person

private

  def allow_only_submit_domain
    raise "Not a submit domain" unless submit_domain?
  end

  def try_to_finish_account_setup
    return unless user_signed_in?
    return unless submit_domain?

    unless current_user.account_security_completed?
      redirect_to registration_new_account_security_path
    end
  end

  def create_or_join_responsible_person
    return unless fully_signed_in_submit_user?
    return unless current_user.mobile_number_verified?

    responsible_person = current_responsible_person

    if responsible_person.blank?
      if current_user.responsible_persons.present?
        redirect_to select_responsible_persons_path
      else
        redirect_to account_path(:overview)
      end
    elsif responsible_person.contact_persons.empty?
      redirect_to new_responsible_person_contact_person_path(responsible_person)
    end
  end

  def fully_signed_in_submit_user?
    if Rails.configuration.secondary_authentication_enabled
      user_signed_in? && secondary_authentication_present?
    else
      user_signed_in?
    end
  end

  def authorize_user!
    redirect_to invalid_account_path if current_user && !current_user.is_a?(SubmitUser)
  end

  def set_current_responsible_person(responsible_person)
    current_user.update!(current_responsible_person_id: responsible_person.id)
  end
end
