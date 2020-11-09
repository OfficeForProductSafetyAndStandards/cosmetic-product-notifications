require "rails_helper"

RSpec.describe PendingResponsiblePersonInvitationsPresenter do
  describe "#invitations_by_responsible_person" do
    subject(:presenter) { described_class.new(invitations) }

    before do
      travel_to Time.zone.local(2020, 11, 24)
    end

    context "when having invitations for different responsible persons" do
      let(:invitations) { build_stubbed_list(:pending_responsible_person_user, 2) }

      it "returns a hash with the responsible person names from the invitations as keys" do
        expect(presenter.responsible_persons_invitations_text.keys)
          .to eq [invitations.first.responsible_person.name, invitations.last.responsible_person.name]
      end
    end

    context "when having a single invitation for a responsible person" do
      let(:invitations) { [build_stubbed(:pending_responsible_person_user)] }

      it "displays the date of invitation" do
        rp_name = invitations.first.responsible_person.name
        expect(presenter.responsible_persons_invitations_text[rp_name]).to eq(
          "Check your email inbox for your invite, sent <span class='no-wrap'>24 November 2020.</span>",
        )
      end
    end

    context "when having a single expired invitation for a responsible person" do
      let(:invitations) { [build_stubbed(:pending_responsible_person_user, :expired)] }

      it "displays the name of the user who sent of invitation" do
        rp_name = invitations.first.responsible_person.name
        expect(presenter.responsible_persons_invitations_text[rp_name]).to eq(
          "Your invite has expired and needs to be resent. " \
          "You were invited by <span class='no-wrap'>#{invitations.first.inviting_user.name}.</span>",
        )
      end
    end

    context "when having multiple expired invitations for a responsible person" do
      let(:invitations) do
        build_stubbed_list(:pending_responsible_person_user, 3, :expired, responsible_person: build_stubbed(:responsible_person))
      end

      # rubocop:disable RSpec/ExampleLength
      it "displays the name of the user who sent of invitation" do
        rp_name = invitations.first.responsible_person.name
        expect(presenter.responsible_persons_invitations_text[rp_name]).to eq(
          "Your invite has expired and needs to be resent. You were invited by " \
          "<span class='no-wrap'>#{invitations.first.inviting_user.name}</span>, " \
          "<span class='no-wrap'>#{invitations.second.inviting_user.name}</span> " \
          "and <span class='no-wrap'>#{invitations.third.inviting_user.name}.</span>",
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context "when having multiple invitations including some expired for a responsible person" do
      let(:responsible_person) { build_stubbed(:responsible_person) }
      let(:invitations) do
        [
          build_stubbed(:pending_responsible_person_user, :expired, responsible_person: responsible_person, created_at: 3.days.ago),
          build_stubbed(:pending_responsible_person_user, responsible_person: responsible_person, created_at: 1.day.ago),
          build_stubbed(:pending_responsible_person_user, responsible_person: responsible_person),
          build_stubbed(:pending_responsible_person_user, :expired, responsible_person: responsible_person, created_at: 2.days.ago),
        ]
      end

      it "displays the date of the newest active invitation" do
        rp_name = invitations.first.responsible_person.name
        expect(presenter.responsible_persons_invitations_text[rp_name]).to eq(
          "Check your email inbox for your invite, sent <span class='no-wrap'>24 November 2020.</span>",
        )
      end
    end
  end
end
