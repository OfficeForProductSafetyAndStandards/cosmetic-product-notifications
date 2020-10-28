module ResponsiblePersonHelpers
  def sign_in_as_member_of_responsible_person(responsible_person, user = nil)
    user ||= build(:submit_user)
    responsible_person.add_user(user) unless user.responsible_persons.include? responsible_person

    configure_requests_for_submit_domain
    sign_in user
  end
end
