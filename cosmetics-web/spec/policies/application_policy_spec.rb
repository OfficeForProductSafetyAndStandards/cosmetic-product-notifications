require "rails_helper"

RSpec.describe ApplicationPolicy, type: :policy do
  subject { ApplicationPolicy.new(user, record) }

  let(:user) { create(:user) }
  let(:record) { create(:notification) }

  it { is_expected.not_to permit(:index) }
  it { is_expected.not_to permit(:create)  }
  it { is_expected.not_to permit(:new)     }
  it { is_expected.not_to permit(:update)  }
  it { is_expected.not_to permit(:edit)    }
  it { is_expected.not_to permit(:destroy) }
end
