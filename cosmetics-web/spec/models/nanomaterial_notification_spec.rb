require "rails_helper"

RSpec.describe NanomaterialNotification, type: :model do
  describe "validations" do
    describe "IUPAC name" do
      context "when not setting a name" do
        let(:nanomaterial_notification) { described_class.new }

        before do
          nanomaterial_notification.valid?(:add_iupac_name)
        end

        it "adds an error" do
          expect(nanomaterial_notification.errors[:iupac_name]).to include("Enter an IUPAC name")
        end
      end

      context "when setting a name" do
        let(:nanomaterial_notification) { described_class.new(iupac_name: "Test name") }

        it "is valid" do
          expect(nanomaterial_notification.valid?(:add_iupac_name)).to be true
        end
      end
    end

    describe "EU notification" do
      context "when not specified" do
        let(:nanomaterial_notification) do
          described_class.new(eu_notified: nil)
        end

        before do
          nanomaterial_notification.valid?(:eu_notification)
        end

        it "adds an error" do
          expect(nanomaterial_notification.errors[:eu_notified]).to include("Select whether the EU was notified")
        end
      end

      context "when the EU was notified but no date set" do
        let(:nanomaterial_notification) do
          described_class.new(eu_notified: true, notified_to_eu_on: nil)
        end

        before do
          nanomaterial_notification.valid?(:eu_notification)
        end

        it "adds an error" do
          expect(nanomaterial_notification.errors[:notified_to_eu_on]).to include("Enter the date the EU was notified on")
        end
      end

      context "when the EU was notified and a pre-Brexit date is set" do
        let(:nanomaterial_notification) do
          described_class.new(eu_notified: true, notified_to_eu_on: Date.parse("2020-01-20"))
        end

        it "is valid" do
          expect(nanomaterial_notification.valid?(:eu_notification)).to be(true), nanomaterial_notification.errors.full_messages.to_s
        end
      end

      context "when the EU was notified and a post-Brexit date is set" do
        let(:nanomaterial_notification) do
          described_class.new(eu_notified: true, notified_to_eu_on: Date.parse("2020-02-02"))
        end

        before do
          nanomaterial_notification.valid?(:eu_notification)
        end

        it "adds an error" do
          expect(nanomaterial_notification.errors[:notified_to_eu_on]).to include("Enter a date before Brexit")
        end
      end

      context "when the EU was not notified and no date is set" do
        let(:nanomaterial_notification) do
          described_class.new(eu_notified: false, notified_to_eu_on: nil)
        end

        it "is valid" do
          expect(nanomaterial_notification.valid?(:eu_notification)).to be(true)
        end
      end

      context "when the EU was not notified but a date has been set" do
        let(:nanomaterial_notification) do
          described_class.new(eu_notified: false, notified_to_eu_on: Date.parse("2020-04-02"))
        end

        before do
          nanomaterial_notification.valid?(:eu_notification)
        end

        it "adds an error" do
          expect(nanomaterial_notification.errors[:notified_to_eu_on]).to include("Remove date or change answer to Yes")
        end
      end
    end
  end
end
