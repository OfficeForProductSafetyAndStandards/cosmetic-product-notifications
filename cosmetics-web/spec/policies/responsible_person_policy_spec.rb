require "rails_helper"

RSpec.describe ResponsiblePersonPolicy, type: :policy do
  subject(:policy) { described_class.new(user, responsible_person) }

  let(:user) { create(:submit_user) }
  let(:responsible_person) { create(:responsible_person) }

  it { is_expected.not_to permit(:index) }
  it { is_expected.not_to permit(:create)  }
  it { is_expected.not_to permit(:new)     }
  it { is_expected.not_to permit(:update)  }
  it { is_expected.not_to permit(:edit)    }
  it { is_expected.not_to permit(:destroy) }

  describe "#show" do
    it "does not permit when user and responsible person are not in the same team" do
      expect(policy).not_to permit(:show)
    end

    it "permits when user and responsible person are in the same team" do
      ResponsiblePersonUser.create(user:, responsible_person:)

      expect(policy).to permit(:show)
    end

    it "permits when user is invited by responsible person" do
      create(:pending_responsible_person_user, email_address: user.email, responsible_person:)

      expect(policy).to permit(:show)
    end
  end
end
