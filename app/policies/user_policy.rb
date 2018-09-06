class UserPolicy < ApplicationPolicy
  def index?
    @user.has_role? :admin
  end

  def show?
    @user.has_role?(:admin) || @user == @record
  end
end
