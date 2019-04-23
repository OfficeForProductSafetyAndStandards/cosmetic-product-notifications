require "rails_helper"

RSpec.describe PoisonCentreNotificationPolicy, type: :policy do
  subject { PoisonCentreNotificationPolicy.new(user, notification) }

  let(:user) { create(:user) }
  let(:notification) { create(:notification) }

  before do
    sign_in_as_poison_centre_user(user: user)
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
