class SubmitApplicationController < ApplicationController
  include ResponsiblePersonConcern

  before_action :allow_only_submit_domain
  before_action :try_to_finish_account_setup
  before_action :has_accepted_declaration
  before_action :create_or_join_responsible_person

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

  def authorize_user!
    redirect_to invalid_account_path if current_user && !current_user.is_a?(SubmitUser)
  end
end
