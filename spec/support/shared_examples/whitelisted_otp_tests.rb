require "rails_helper"

RSpec.shared_examples "whitelisted OTP tests" do
  shared_examples_for "successful auth" do
    specify do
      expect(secondary_authentication).to be_valid_otp(whitelisted_otp)
    end
  end

  shared_examples_for "failed auth" do
    specify do
      expect(secondary_authentication).not_to be_valid_otp(whitelisted_otp)
    end
  end

  let(:application_uris) { %w[foo] }

  let(:vcap_application) do
    { "application_uris" => application_uris }.to_json
  end

  before do
    stub_const("#{described_class}::WHITELISTED_OTP_CODE", whitelisted_otp)
    allow(Rails.configuration).to receive(:vcap_application).and_return(vcap_application)
  end

  context "when ENV['VCAP_APPLICATION'] doesn't exist" do
    it_behaves_like "failed auth"
  end

  context "when ENV['VCAP_APPLICATION'] is string" do
    let(:vcap_application) { "foo" }

    it_behaves_like "failed auth"
  end

  context "when ENV['VCAP_APPLICATION'] is empty hash" do
    let(:vcap_application) do
      {}.to_json
    end

    it_behaves_like "failed auth"
  end

  context "when ENV['VCAP_APPLICATION'] does not have application_uris key" do
    let(:vcap_application) do
      { "foo" => "bar" }.to_json
    end

    it_behaves_like "failed auth"
  end

  context "when ENV['VCAP_APPLICATION'] application_uris key is string" do
    let(:application_uris) { "foo" }

    it_behaves_like "failed auth"
  end

  context "when ENV['VCAP_APPLICATION'] application_uris key is empty array" do
    let(:application_uris) { [] }

    it_behaves_like "failed auth"
  end

  context "when ENV['VCAP_APPLICATION'] application_uris doesn't fit allowed url" do
    let(:application_uris) { %w[foo] }

    it_behaves_like "failed auth"
  end

  context "when ENV['VCAP_APPLICATION'] application_uris has more than 2 values" do
    let(:application_uris) do
      ["staging-submit.cosmetic-product-notifications.service.gov.uk",
       "staging-submit2.cosmetic-product-notifications.service.gov.uk",
       "staging-search.cosmetic-product-notifications.service.gov.uk"]
    end

    it_behaves_like "failed auth"
  end

  context "when ENV['VCAP_APPLICATION'] application_uris is production url" do
    let(:application_uris) { ["submit.cosmetic-product-notifications.service.gov.uk"] }

    it_behaves_like "failed auth"
  end

  context "when ENV['VCAP_APPLICATION'] application_uris is staging url" do
    let(:application_uris) { ["staging-submit.cosmetic-product-notifications.service.gov.uk"] }

    it_behaves_like "successful auth"

    it "fails using a non whitelisted OTP" do
      expect(secondary_authentication).not_to be_valid_otp(whitelisted_otp.reverse)
    end
  end

  context "when ENV['VCAP_APPLICATION'] application_uris is review app url" do
    let(:application_uris) { ["cosmetics-pr-1730-submit-web.london.cloudapps.digital"] }

    it_behaves_like "successful auth"

    it "fails using a non whitelisted OTP" do
      expect(secondary_authentication).not_to be_valid_otp(whitelisted_otp.reverse)
    end
  end
end
