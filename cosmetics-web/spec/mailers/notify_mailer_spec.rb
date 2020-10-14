require "rails_helper"

RSpec.describe NotifyMailer, type: :mailer do
  let(:responsible_person) { build_stubbed(:responsible_person) }
  let(:invited_team_member) { build_stubbed(:pending_responsible_person_user, responsible_person: responsible_person) }
  let(:inviting_user_name) { "Test User" }

  describe "send_responsible_person_invite_email" do
    it "sends invite to join a responsible person to invited user" do
      mail = described_class.send_responsible_person_invite_email(responsible_person, invited_team_member, inviting_user_name)
      expect(mail.to).to eq([invited_team_member.email_address])
    end
  end
end
