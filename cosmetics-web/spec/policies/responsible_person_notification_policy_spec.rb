require "rails_helper"

RSpec.describe ResponsiblePersonNotificationPolicy, type: :policy do
  subject { described_class.new(user, notification) }

  let(:user) { create(:user) }
  let(:notification) { create(:notification) }

  describe "when user and notification's responsible person are not in the same team" do
    it { is_expected.not_to permit(:index) }
    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:new)     }
    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
    it { is_expected.not_to permit(:upload_formulation) }
    it { is_expected.not_to permit(:confirm) }
  end

  describe "when user and notification's responsible person are in the same team" do
    before do
      responsible_person = create(:responsible_person)

      notification.responsible_person = responsible_person
      create(:responsible_person_user, user: user, responsible_person: responsible_person)
    end

    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:create)  }
    it { is_expected.to permit(:new)     }
    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:update)  }
    it { is_expected.to permit(:edit)    }
    it { is_expected.to permit(:upload_formulation) }
    it { is_expected.to permit(:confirm) }

    it { is_expected.not_to permit(:destroy) }
  end
end
