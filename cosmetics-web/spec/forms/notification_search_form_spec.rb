require "rails_helper"

RSpec.describe NotificationSearchForm do
  let(:q) { "Soap" }
  let(:category) { nil }
  let(:date_from_year) { nil }
  let(:date_from_month) { nil }
  let(:date_from_day) { nil }
  let(:date_to_year) { nil }
  let(:date_to_month) { nil }
  let(:date_to_day) { nil }
  let(:date_exact_year) { nil }
  let(:date_exact_month) { nil }
  let(:date_exact_day) { nil }
  let(:date_filter) { nil }

  subject do
    described_class.new(q: q,
                        category: category,
                        date_from_year: date_from_year,
                        date_from_month: date_from_month,
                        date_from_day: date_from_day,
                        date_to_year: date_to_year,
                        date_to_month: date_to_month,
                        date_to_day: date_to_day,
                        date_exact_year: date_exact_year,
                        date_exact_month: date_exact_month,
                        date_exact_day: date_exact_day,
                        date_filter: date_filter
                       )
  end

  describe "validations" do
    before { subject.valid? }

    context "when dates are present" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when dates are not present" do
      context "when using exact date filter" do
        let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_EXACT }

        let(:date_exact_year) { "2021" }
        let(:date_exact_month) { "06" }
        let(:date_exact_day) { "01" }


        context "when year is missing" do
          let(:date_exact_year) { nil }

          it "has error" do
            expect(subject.errors[:date_exact_year]).to be_present
          end
        end

        context "when month is missing" do
          let(:date_exact_month) { nil }

          it "has error" do
            expect(subject.errors[:date_exact_month]).to be_present
          end
        end

        context "when day is missing" do
          let(:date_exact_day) { nil }

          it "has error" do
            expect(subject.errors[:date_exact_day]).to be_present
          end
        end
      end
    end

    context "When dates are invalid" do
        let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_EXACT }

        let(:date_exact_year) { "2021" }
        let(:date_exact_month) { "66" }
        let(:date_exact_day) { "01" }

        it "has error" do
          expect(subject.errors.of_kind? :date_exact_year, :invalid_date).to be_present
        end

    end
  end
end
