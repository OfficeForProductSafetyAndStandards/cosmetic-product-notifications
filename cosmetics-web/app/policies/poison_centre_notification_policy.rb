class PoisonCentreNotificationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all if user.poison_centre_user? || user.opss_user? || user.trading_standards_user?
    end
  end

  def index?
    show?
  end

  def show?
    user.poison_centre_user? || user.opss_user? || user.trading_standards_user?
  end

  def full_address_history?
    user.can_view_notification_history?
  end

end
