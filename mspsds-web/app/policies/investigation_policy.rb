class InvestigationPolicy < ApplicationPolicy
  def destroy?
    @user.has_role? :admin
  end

  def visible?
    return true unless @record.is_private

    # TODO MSPSDS-859: Replace users with organizations when we get organizations
    @record.who_can_see.include?(@user.id)
  end
end
