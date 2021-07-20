module ResponsiblePersons
  class InviteMemberForm < Form
    include StripWhitespace

    attribute :name
    attribute :responsible_person

    validates_presence_of :name
    include EmailFormValidation

    validate :email_not_invited
    validate :email_not_member

  private

    def email_not_invited
      if PendingResponsiblePersonUser.where(responsible_person: responsible_person, email_address: email).any?
        errors.add :email, :taken
      end
    end

    def email_not_member
      if responsible_person.has_user_with_email?(email)
        errors.add :email, :taken_team
      end
    end
  end
end
