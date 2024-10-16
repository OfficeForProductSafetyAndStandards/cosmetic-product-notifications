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

  def index?
    update?
  end

  def delete?
    user_member_of_associated_responsible_person? && record.can_be_deleted?
  end

  def destroy?
    user_member_of_associated_responsible_person? && record.can_be_deleted?
  end

  def choose_archive_reason?
    user_member_of_associated_responsible_person?
  end

  def archive?
    user_member_of_associated_responsible_person?
  end

  def unarchive?
    user_member_of_associated_responsible_person?
  end

  def search?
    user.can_search_for_ingredients?
  end

private

  def pundit_user
    current_submit_user
  end

  def user_member_of_associated_responsible_person?
    user.responsible_persons.include?(record&.responsible_person)
  end

  def notification_is_not_submitted?
    !record&.notification_complete?
  end
end
