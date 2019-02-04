module ResponsiblePersonHelpers
  def sign_in_as_member_of_responsible_person(responsible_person)
    user = build(:user)
    responsible_person.add_team_member(user)
    sign_in as_user: user
  end
end
