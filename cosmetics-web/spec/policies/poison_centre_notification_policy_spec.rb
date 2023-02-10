require "rails_helper"

RSpec.describe PoisonCentreNotificationPolicy, type: :policy do
  subject { described_class.new(user, notification) }

  let(:notification) { build_stubbed(:notification) }

  context "with a poison centre user" do
    let(:user) { build_stubbed(:poison_centre_user) }

    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:show) }

    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:new)     }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
  end

  context "with an OPSS General user" do
    let(:user) { build_stubbed(:opss_general_user) }

    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:show) }

    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:new)     }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
  end

  context "with an OPSS Enforcement user" do
    let(:user) { build_stubbed(:opss_enforcement_user) }

    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:show) }

    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:new)     }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
  end

  context "with a Trading Standards user" do
    let(:user) { build_stubbed(:trading_standards_user) }

    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:show) }

    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:new)     }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
  end

  context "with an OPSS Science user" do
    let(:user) { build_stubbed(:opss_science_user) }

    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:show) }

    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:new)     }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
  end

  context "with neither a poison centre/OPSS General/OPSS Enforcement/OPSS Science/Trading Standards user" do
    let(:user) { build_stubbed(:search_user) }

    it { is_expected.not_to permit(:index) }
    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update) }
    it { is_expected.not_to permit(:edit) }
    it { is_expected.not_to permit(:destroy) }
  end
end
