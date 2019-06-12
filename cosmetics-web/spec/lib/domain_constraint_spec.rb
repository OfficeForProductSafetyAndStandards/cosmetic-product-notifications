require "rails_helper"

RSpec.describe DomainConstraint, type: :constraint do
  let(:expected_domain) { "www.example.com" }
  let(:other_domain) { "other.example.com" }

  let(:domain_constraint) { DomainConstraint.new(expected_domain) }

  describe "#matches?" do
    it "returns true for requests with the expected domain" do
      request = ActionDispatch::Request.new("HTTP_HOST" => expected_domain)
      expect(domain_constraint.matches?(request)).to be true
    end

    it "returns false for requests with a different domain" do
      request = ActionDispatch::Request.new("HTTP_HOST" => other_domain)
      expect(domain_constraint.matches?(request)).to be false
    end
  end

  context "when configured with multiple comma-separated domains" do
    let(:multiple_expected_domains) { "www.example.com,expected.example.com" }
    let(:domain_constraint) { DomainConstraint.new(multiple_expected_domains) }

    describe "#matches?" do
      it "returns true for requests with either expected domain" do
        request1 = ActionDispatch::Request.new("HTTP_HOST" => "www.example.com")
        request2 = ActionDispatch::Request.new("HTTP_HOST" => "expected.example.com")
        expect(domain_constraint.matches?(request1)).to be true
        expect(domain_constraint.matches?(request2)).to be true
      end

      it "returns false for requests with a different domain" do
        request = ActionDispatch::Request.new("HTTP_HOST" => other_domain)
        expect(domain_constraint.matches?(request)).to be false
      end
    end
  end
end
