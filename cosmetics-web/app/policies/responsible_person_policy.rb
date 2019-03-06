class ResponsiblePersonPolicy < ApplicationPolicy
  def show?
    user.responsible_persons.include?(record)
  end
end
