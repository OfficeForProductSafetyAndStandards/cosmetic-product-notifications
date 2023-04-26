# rubocop:disable Style/ExplicitBlockArgument
def with_feature_flag_enabled(feature_flag_name)
  before do
    Flipper.enable(feature_flag_name)
  end

  context "with feature flag #{feature_flag_name} enabled" do
    yield
  end
end

def with_feature_flag_disabled(feature_flag_name)
  before do
    Flipper.disable(feature_flag_name)
  end

  context "with feature flag #{feature_flag_name} disabled" do
    yield
  end
end
# rubocop:enable Style/ExplicitBlockArgument
