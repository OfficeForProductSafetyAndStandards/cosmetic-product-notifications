class PoisonCentreNotificationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all if user.poison_centre_or_msa_user
    end
  end

  def index?
    user.poison_centre_or_msa_user?
  end

  def show?
    user.poison_centre_or_msa_user?
  end
end
