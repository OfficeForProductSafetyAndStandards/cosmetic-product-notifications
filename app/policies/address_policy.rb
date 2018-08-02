class AddressPolicy < ApplicationPolicy
  def update?
    !@record.from_companies_house?
  end

  def destroy?
    !@record.from_companies_house?
  end
end
