class PoisonCentreNotificationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all if user.poison_centre_user? || user.msa_user?
    end
  end

  def index?
    show?
  end

  def show?
    user.poison_centre_user? || user.msa_user?
  end
end
