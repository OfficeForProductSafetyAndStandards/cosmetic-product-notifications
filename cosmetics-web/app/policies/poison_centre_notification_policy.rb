class PoisonCentreNotificationPolicy < ApplicationPolicy
  ALLOWED_SCOPE_ROLES = %i[poison_centre opss_general trading_standards].freeze
  ALLOWED_SHOW_ROLES = (ALLOWED_SCOPE_ROLES + %i[opss_enforcement opss_imt opss_science]).freeze

  class Scope < Scope
    def resolve
      if user_has_any_role?(ALLOWED_SCOPE_ROLES)
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    show?
  end

  def show?
    user_has_any_role?(ALLOWED_SHOW_ROLES)
  end

  def full_address_history?
    user.can_view_notification_history?
  end

private

  def user_has_any_role?(roles)
    roles.any? { |role| user.has_role?(role) }
  end
end
