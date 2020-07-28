require "rails_helper"

RSpec.describe PoisonCentreNotificationPolicy, type: :policy do
  subject { described_class.new(user, notification) }

  let(:user) { build_stubbed(:search_user, access_token: "access_token") }
  let(:notification) { build_stubbed(:notification) }

  context "with a poison centre user" do
    before do
      allow(user).to receive(:poison_centre_user?).and_return(true)
      allow(user).to receive(:msa_user?).and_return(false)
    end

    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:show) }

    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:new)     }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
  end

  context "with a msa user" do
    before do
      allow(user).to receive(:poison_centre_user?).and_return(false)
      allow(user).to receive(:msa_user?).and_return(true)
    end

    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:show) }

    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:new)     }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
  end

  context "with neither a poison centre or msa user" do
    before do
      allow(user).to receive(:poison_centre_user?).and_return(false)
      allow(user).to receive(:msa_user?).and_return(false)
    end

    it { is_expected.not_to permit(:index) }
    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update) }
    it { is_expected.not_to permit(:edit) }
    it { is_expected.not_to permit(:destroy) }
  end
end
