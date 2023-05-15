def with_feature_flag_enabled(feature_flag_name, &block)
  context "with feature flag #{feature_flag_name} enabled" do
    before do
      Flipper.enable(feature_flag_name)
    end

    class_exec(&block)
  end
end

def with_feature_flag_disabled(feature_flag_name, &block)
  context "with feature flag #{feature_flag_name} disabled" do
    before do
      Flipper.disable(feature_flag_name)
    end

    class_exec(&block)
  end
end

def with_feature_flag_both_enabled_and_disabled(feature_flag_name, &block)
  context "with feature flag #{feature_flag_name} enabled" do
    before do
      Flipper.enable(feature_flag_name)
    end

    class_exec(true, &block)
  end

  context "with feature flag #{feature_flag_name} disabled" do
    before do
      Flipper.disable(feature_flag_name)
    end

    class_exec(false, &block)
  end
end
