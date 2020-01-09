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

      context "when the EU was notified but an invalid date has been set" do
        let(:nanomaterial_notification) do
          described_class.new(eu_notified: true, notified_to_eu_on: { day: "12", month: "24", year: "2019" })
        end

        before do
          nanomaterial_notification.valid?(:eu_notification)
        end

        it "adds an error" do
          expect(nanomaterial_notification.errors[:notified_to_eu_on]).to include("Enter a real EU notification date")
        end
      end

      context "when a day is missing from the date" do
        let(:nanomaterial_notification) do
          described_class.new(eu_notified: true, notified_to_eu_on: { day: "", month: "01", year: "2019" })
        end

        before do
          nanomaterial_notification.valid?(:eu_notification)
        end

        it "adds an error" do
          expect(nanomaterial_notification.errors[:notified_to_eu_on]).to include("EU notification date must include a day")
        end
      end

      context "when a month is missing from the date" do
        let(:nanomaterial_notification) do
          described_class.new(eu_notified: true, notified_to_eu_on: { day: "01", month: "", year: "2019" })
        end

        before do
          nanomaterial_notification.valid?(:eu_notification)
        end

        it "adds an error" do
          expect(nanomaterial_notification.errors[:notified_to_eu_on]).to include("EU notification date must include a month")
        end
      end

      context "when a year is missing from the date" do
        let(:nanomaterial_notification) do
          described_class.new(eu_notified: true, notified_to_eu_on: { day: "01", month: "01", year: "" })
        end

        before do
          nanomaterial_notification.valid?(:eu_notification)
        end

        it "adds an error" do
          expect(nanomaterial_notification.errors[:notified_to_eu_on]).to include("EU notification date must include a year")
        end
      end

      context "when a day and month are missing from the date" do
        let(:nanomaterial_notification) do
          described_class.new(eu_notified: true, notified_to_eu_on: { day: "", month: "", year: "2019" })
        end

        before do
          nanomaterial_notification.valid?(:eu_notification)
        end

        it "adds an error" do
          expect(nanomaterial_notification.errors[:notified_to_eu_on]).to include("EU notification date must include a day and month")
        end
      end

      context "when the date is blank" do
        let(:nanomaterial_notification) do
          described_class.new(eu_notified: true, notified_to_eu_on: { day: "", month: "", year: "" })
        end

        before do
          nanomaterial_notification.valid?(:eu_notification)
        end

        it "adds an error" do
          expect(nanomaterial_notification.errors[:notified_to_eu_on]).to include("Enter the date the EU was notified about the nanomaterial on CPNP")
        end
      end
    end
  end

  describe "#notified_to_eu_on=" do
    let(:nanomaterial_notification) { described_class.new }

    context "when setting with a date object" do
      before do
        nanomaterial_notification.notified_to_eu_on = Date.new(2019, 1, 2)
      end

      it "sets the date" do
        expect(nanomaterial_notification.notified_to_eu_on).to eql(Date.new(2019, 1, 2))
      end
    end

    context "when setting with nil" do
      before do
        nanomaterial_notification.notified_to_eu_on = nil
      end

      it "sets the date as nil" do
        expect(nanomaterial_notification.notified_to_eu_on).to be nil
      end
    end

    context "when setting with a valid hash" do
      before do
        nanomaterial_notification.notified_to_eu_on = { day: "02", month: "01", year: "2019" }
      end

      it "sets the date" do
        expect(nanomaterial_notification.notified_to_eu_on).to eql(Date.new(2019, 1, 2))
      end
    end

    context "when setting with hash containing an invalid date" do
      before do
        nanomaterial_notification.notified_to_eu_on = { day: "40", month: "13", year: "2019" }
      end

      it "sets an invalid date" do
        expect(nanomaterial_notification.notified_to_eu_on).to eql(OpenStruct.new(day: "40", month: "13", year: "2019"))
      end
    end

    context "when setting with hash containing all blank values" do
      before do
        nanomaterial_notification.notified_to_eu_on = { day: "", month: "", year: "" }
      end

      it "sets an nil date" do
        expect(nanomaterial_notification.notified_to_eu_on).to be nil
      end
    end
  end

  describe "#submittable?", :with_stubbed_antivirus do
    context "when all required questions have been answered" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, :submittable) }

      it "is true" do
        expect(nanomaterial_notification.submittable?).to be true
      end
    end

    context "when the name hasn’t been set" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, name: nil) }

      it "is false" do
        expect(nanomaterial_notification.submittable?).to be false
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

  describe "#can_be_made_available_on_uk_market_from" do
    context "when not submitted yet" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, submitted_at: nil) }

      it "is nil" do
        expect(nanomaterial_notification.can_be_made_available_on_uk_market_from).to be nil
      end
    end

    context "when notified to the EU 6 months or more before Brexit" do
      let(:nanomaterial_notification) {
        create(:nanomaterial_notification,
               submitted_at: Time.zone.parse("2020-02-05T12:00Z"),
               eu_notified: true,
               notified_to_eu_on: Date.parse("2019-07-31"))
      }

      it "is available from the start of the day after Brexit" do
        expect(nanomaterial_notification.can_be_made_available_on_uk_market_from).to eql(Time.zone.parse("2020-01-31T00:00Z"))
      end
    end

    context "when notified to the EU less than 6 months before Brexit" do
      let(:nanomaterial_notification) {
        create(:nanomaterial_notification,
               submitted_at: Time.zone.parse("2020-02-05T12:00Z"),
               eu_notified: true,
               notified_to_eu_on: Date.parse("2019-08-01"))
      }

      it "is available 7 months later" do
        expect(nanomaterial_notification.can_be_made_available_on_uk_market_from).to eql(Time.zone.parse("2020-03-01T00:00Z"))
      end
    end

    context "when notified after Brexit" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, submitted_at: Time.zone.parse("2020-01-01T23:01Z"), notified_to_eu_on: nil, eu_notified: false) }

      it "is available 6 months later" do
        expect(nanomaterial_notification.can_be_made_available_on_uk_market_from).to eql(Time.zone.parse("2020-07-01T00:00 BST +01:00"))
      end
    end

    context "when notified after Brexit between 11pm and mightnight during British Summer Time (BST)" do
      let(:nanomaterial_notification) {
        create(:nanomaterial_notification,
               submitted_at: Time.zone.parse("2020-08-31T23:30Z"),
               notified_to_eu_on: nil,
               eu_notified: false)
      }

      it "is available 6 months later" do
        expect(nanomaterial_notification.can_be_made_available_on_uk_market_from).to eql(Time.zone.parse("2021-03-01T00:00Z"))
      end
    end
  end
end
