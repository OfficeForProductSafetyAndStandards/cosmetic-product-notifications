require "rails_helper"

RSpec.describe ResponsiblePersonNotificationPolicy, type: :policy do
  subject { described_class.new(user, notification) }

  let(:user) { create(:submit_user) }
  let(:notification) { create(:notification) }

  describe "when user and notification's responsible person are not in the same team" do
    it { is_expected.not_to permit(:index) }
    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:new)     }
    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
    it { is_expected.not_to permit(:confirm) }
  end

  describe "when user and notification's responsible person are in the same team" do
    let(:responsible_person) { create(:responsible_person) }

    before do
      notification.responsible_person = responsible_person
      create(:responsible_person_user, user:, responsible_person:)
    end

    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:create)  }
    it { is_expected.to permit(:new)     }
    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:update)  }
    it { is_expected.to permit(:edit)    }
    it { is_expected.to permit(:confirm) }

    it { is_expected.to permit(:destroy) }
  end

  describe "#search?" do
    subject { described_class.new(user, Notification) }

    context "for a OPSS general user" do
      let(:user) { create(:opss_general_user) }

      it { is_expected.not_to permit(:search) }
    end

    context "for a poison centre user" do
      let(:user) { create(:poison_centre_user) }

      it { is_expected.to permit(:search) }
    end

    context "for a OPSS enforcement user" do
      let(:user) { create(:opss_enforcement_user) }

      it { is_expected.to permit(:search) }
    end

    context "for a OPSS IMT user" do
      let(:user) { create(:opss_imt_user) }

      it { is_expected.to permit(:search) }
    end

    context "for a OPSS science user" do
      let(:user) { create(:opss_science_user) }

      it { is_expected.to permit(:search) }
    end

    context "for a trading standards user" do
      let(:user) { create(:trading_standards_user) }

      it { is_expected.to permit(:search) }
    end
  end
end
