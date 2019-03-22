class InvestigationPolicy < ApplicationPolicy
  def show?(user: @user)
    visible_to(user: user)
  end

  def new?
    show?
  end

  def status?
    show?
  end

  def assign?(user: @user)
    can_be_assigned_by(user: user)
  end

  def visibility?(user: @user)
    visible_to(user: user, private: true)
  end

  def created?
    show?
  end

  def visible_to(user:, private: @record.is_private)
    return true if @record.source&.is_a? ReportSource
    return true unless private
    return true if user.is_opss?
    return true if @record.assignee.present? && (@record.assignee&.organisation == user.organisation)
    return true if @record.source&.user&.present? && (@record.source&.user&.organisation == user.organisation)

    false
  end

  def can_be_assigned_by(user: @user)
    return true if @record.assignee.blank?
    return true if @record.assignee.is_a?(Team) && (user.teams.include? @record.assignee)
    return true if @record.assignee.is_a?(User) && (user.teams & @record.assignee.teams).any? || @record.assignee == user

    false
  end

  def user_allowed_to_raise_alert?(user: @user)
    user.is_opss?
  end

  def investigation_restricted?
    !@record.is_private
  end
end
