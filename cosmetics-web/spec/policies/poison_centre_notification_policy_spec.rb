require "rails_helper"

RSpec.describe PoisonCentreNotificationPolicy, type: :policy do
  subject { described_class.new(user, notification) }

  let(:user) { create(:user, access_token: "access_token") }
  let(:notification) { create(:notification) }

  before do
    sign_in_as_poison_centre_user(user: user)

    # This line is needed since the application controller is not called
    current_user = user
  end

  after do
    sign_out
  end

  it { is_expected.to permit(:index) }
  it { is_expected.to permit(:show) }

  it { is_expected.not_to permit(:create)  }
  it { is_expected.not_to permit(:new)     }
  it { is_expected.not_to permit(:update)  }
  it { is_expected.not_to permit(:edit)    }
  it { is_expected.not_to permit(:destroy) }
end
