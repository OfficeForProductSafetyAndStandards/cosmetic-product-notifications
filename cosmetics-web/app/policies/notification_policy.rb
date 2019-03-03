class NotificationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.poison_centre_user?
        scope.all
      else
        scope.where(responsible_person: user.responsible_persons)
      end
    end
  end

  def show?
    user.poison_centre_user? || edit?
  end

  def edit?
    user.responsible_persons.include?(@record.responsible_person)
  end

  def confirmation?
    edit?
  end
end
