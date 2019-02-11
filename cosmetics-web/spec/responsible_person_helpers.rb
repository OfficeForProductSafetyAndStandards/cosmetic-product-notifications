module ResponsiblePersonHelpers
  def sign_in_as_member_of_responsible_person(responsible_person)
    user = build(:user)
    responsible_person.add_user(user)
    sign_in as_user: user
  end

  def sign_in_as_member_of_responsible_person_as_user(responsible_person, user)
    responsible_person.add_user(user)
    sign_in as_user: user
  end
end
