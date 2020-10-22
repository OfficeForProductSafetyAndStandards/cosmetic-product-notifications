module ResponsiblePersonConcern
  extend ActiveSupport::Concern

  included do
    before_action :validate_responsible_person
  end

  def validate_responsible_person
    return if @responsible_person.nil?

    if @responsible_person != current_user.current_responsible_person
      redirect_to select_responsible_person_path(current_user.current_responsible_person)
    end
  end
end
