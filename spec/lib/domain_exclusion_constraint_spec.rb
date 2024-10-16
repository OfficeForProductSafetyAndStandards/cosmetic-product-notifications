require "rails_helper"

RSpec.describe DomainExclusionConstraint, type: :constraint do
  subject(:constraint) { described_class.new(*excluded_domain) }

  let(:excluded_domain) { %w[www.example.com] }

  describe "#matches?" do
    it "returns false for requests with the excluded domain" do
      request = ActionDispatch::Request.new("HTTP_HOST" => "www.example.com")
      expect(constraint.matches?(request)).to be false
    end

    it "returns true for requests with different domain from excluded one" do
      request = ActionDispatch::Request.new("HTTP_HOST" => "other.example.com")
      expect(constraint.matches?(request)).to be true
    end

    shared_examples_for "constraint check against multiple domains" do
      it "returns false for requests with either excluded domain" do
        request1 = ActionDispatch::Request.new("HTTP_HOST" => "www.example.com")
        request2 = ActionDispatch::Request.new("HTTP_HOST" => "excluded.example.com")
        expect(constraint.matches?(request1)).to be false
        expect(constraint.matches?(request2)).to be false
      end

      it "returns true for requests with different domain from excluded ones" do
        request = ActionDispatch::Request.new("HTTP_HOST" => "other.example.com")
        expect(constraint.matches?(request)).to be true
      end
    end

    context "when configured with multiple domains" do
      let(:excluded_domain) { %w[www.example.com excluded.example.com] }

      include_examples "constraint check against multiple domains"
    end

    context "when configured with multiple domains with extra spaces" do
      let(:excluded_domain) { ["www.example.com", " excluded.example.com"] }

      include_examples "constraint check against multiple domains"
    end
  end
end
