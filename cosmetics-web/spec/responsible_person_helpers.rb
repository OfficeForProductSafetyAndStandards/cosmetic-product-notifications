module ResponsiblePersonHelpers
  def sign_in_as_member_of_responsible_person(responsible_person, user = nil)
    user ||= build(:user)
    responsible_person.add_user(user)

    sign_in as_user: user
    configure_requests_for_submit_domain
  end
end
