class Submit::LandingPageController < SubmitApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_secondary_authentication
  skip_before_action :require_secondary_authentication
  before_action :set_responsible_person

  layout "landing_page"

  def index; end

private

  def set_responsible_person
    return unless user_signed_in?

    @responsible_person = if current_responsible_person.present?
                            current_responsible_person
                          elsif current_user.responsible_persons.size == 1
                            current_user.responsible_persons.first
                          end
  end
end
