require "rails_helper"

RSpec.describe NanomaterialNotification, type: :model do
  describe "validations" do
    describe "name" do
      context "when not setting a name" do
        let(:nanomaterial_notification) { described_class.new }

        before do
          nanomaterial_notification.valid?(:add_name)
        end

        it "adds an error" do
          expect(nanomaterial_notification.errors[:name]).to include("Enter the name of the nanomaterial")
        end
      end

      context "when setting a name" do
        let(:nanomaterial_notification) { described_class.new(name: "Test name") }

        it "is valid" do
          expect(nanomaterial_notification.valid?(:add_name)).to be true
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
          expect(nanomaterial_notification.errors[:eu_notified]).to include("Select yes if the EU was notified about the nanomaterial before 1 February 2020")
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
          expect(nanomaterial_notification.errors[:notified_to_eu_on]).to include("Enter the date the EU was notified about the nanomaterial on CPNP")
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
          expect(nanomaterial_notification.errors[:notified_to_eu_on]).to include("The date the EU was notified on CPNP must be before 1 February 2020")
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

  describe "#submitted?" do
    context "when a submitted_at date is present" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, submitted_at: 1.hour.ago) }

      it "is true" do
        expect(nanomaterial_notification.submitted?).to be true
      end
    end

    context "when no submitted_at date is present" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, submitted_at: nil) }

      it "is false" do
        expect(nanomaterial_notification.submitted?).to be false
      end
    end
  end

  describe "#submit!" do
    context "when not previously submitted" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, submitted_at: nil) }

      before { nanomaterial_notification.submit! }

      it "sets a submission date and time" do
        expect(nanomaterial_notification.reload.submitted_at).to be_within(1.second).of(Time.zone.now)
      end
    end

    context "when previously submitted" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, submitted_at: 1.hour.ago) }

      it "raises an error" do
        expect {
          nanomaterial_notification.submit!
        }.to raise_error(NanomaterialNotification::AlreadySubmittedError)
      end
    end
  end
end
