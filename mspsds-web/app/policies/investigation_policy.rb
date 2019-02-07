class InvestigationPolicy < ApplicationPolicy
  def destroy?
    @user.has_role? :admin
  end

  def show?(user: @user)
    visible_to(user: user)
  end

  def assign?
    @record.can_be_assigned_by(@user)
  end

  def visibility?
    visible_to(private: true)
  end

  def visible_to(user: @user, private: @record.is_private)
    return true unless private
    return true if @record.assignee.present? && (@record.assignee&.organisation == user.organisation)
    return true if @record.source.respond_to?(:user) && @record.source&.user&.present? && (@record.source&.user&.organisation == user.organisation)
    return true if user.is_opss?

    false
  end

end
