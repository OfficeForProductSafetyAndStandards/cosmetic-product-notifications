module ResponsiblePersons
  class DetailsForm < Form
    include StripWhitespace

    attribute :name
    attribute :address_line_1
    attribute :address_line_2
    attribute :city
    attribute :county
    attribute :postal_code
    attribute :user

    validates :name, presence: true
    validates :address_line_1, presence: true
    validates :city, presence: true
    validates :postal_code, presence: true
    validates :postal_code, uk_postcode: true, if: -> { postal_code.present? }
    validate :user_not_member_of_rp_with_same_name
    validate :user_not_invited_to_rp_with_same_name

    def user_not_member_of_rp_with_same_name
      return if errors[:name].present?

      if user.responsible_persons.any? { |rp| rp.name.casecmp(name&.strip).zero? }
        errors.add(:name, "You are already associated with #{name}")
      end
    end

    def user_not_invited_to_rp_with_same_name
      return if errors[:name].present?

      if active_invitations_to_rp_with_same_name.any?
        errors.add(:name, "You have already been invited to join #{name}. Check your email inbox for your invite")
      end
    end

  private

    def active_invitations_to_rp_with_same_name
      PendingResponsiblePersonUser
        .joins(:responsible_person)
        .where("email_address = ? AND LOWER(responsible_persons.name) = ? AND invitation_token_expires_at > ?",
               user.email,
               name&.strip&.downcase,
               Time.zone.now)
    end
  end
end
