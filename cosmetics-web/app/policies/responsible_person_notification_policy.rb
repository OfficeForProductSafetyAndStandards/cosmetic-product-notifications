class ResponsiblePersonNotificationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(responsible_person: user.responsible_persons)
    end
  end

  def show?
    user_member_of_associated_responsible_person?
  end

  def create?
    user_member_of_associated_responsible_person?
  end

  def update?
    user_member_of_associated_responsible_person? && notification_is_not_submitted?
  end

  def confirm?
    create?
  end

  def upload_formulation?
    update?
  end

  def index?
    update?
  end

  def delete?
    update?
  end

  def destroy?
    update?
  end

private

  def user_member_of_associated_responsible_person?
    user.responsible_persons.include?(record&.responsible_person)
  end

  def notification_is_not_submitted?
    !record&.notification_complete?
  end
end
