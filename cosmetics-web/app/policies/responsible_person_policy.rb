class ResponsiblePersonPolicy < ApplicationPolicy
  def show?
    @user.responsible_persons.include?(record) || record.pending_responsible_person_users.exists?(email_address: @user.email)
  end
end
