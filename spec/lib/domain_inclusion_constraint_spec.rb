require "rails_helper"

RSpec.describe DomainInclusionConstraint, type: :constraint do
  subject(:constraint) { described_class.new(*expected_domain) }

  let(:expected_domain) { %w[www.example.com] }

  describe "#matches?" do
    it "returns true for requests with the expected domain" do
      request = ActionDispatch::Request.new("HTTP_HOST" => "www.example.com")
      expect(constraint.matches?(request)).to be true
    end

    it "returns false for requests with a different domain" do
      request = ActionDispatch::Request.new("HTTP_HOST" => "other.example.com")
      expect(constraint.matches?(request)).to be false
    end

    context "when no expected domain is given" do
      let(:expected_domain) { [] }

      it "raises an error" do
        request = ActionDispatch::Request.new("HTTP_HOST" => "other.example.com")

        expect { constraint.matches?(request) }
          .to raise_error "No domains specified"
      end
    end

    shared_examples_for "constraint check against multiple domains" do
      it "returns true for requests with either expected domain" do
        request1 = ActionDispatch::Request.new("HTTP_HOST" => "www.example.com")
        request2 = ActionDispatch::Request.new("HTTP_HOST" => "expected.example.com")
        expect(constraint.matches?(request1)).to be true
        expect(constraint.matches?(request2)).to be true
      end

      it "returns false for requests with a different domain from expected ones" do
        request = ActionDispatch::Request.new("HTTP_HOST" => "other.example.com")
        expect(constraint.matches?(request)).to be false
      end
    end

    context "when configured with multiple domains" do
      let(:expected_domain) { %w[www.example.com expected.example.com] }

      include_examples "constraint check against multiple domains"
    end

    context "when configured with multiple domains with extra spaces" do
      let(:expected_domain) { ["www.example.com", " expected.example.com"] }

      include_examples "constraint check against multiple domains"
    end
  end
end
