require "rails_helper"

RSpec.describe NotificationSearchForm do
  subject(:form) do
    described_class.new(q: q,
                        category: category,
                        date_from: date_from,
                        date_to: date_to,
                        date_exact: date_exact,
                        date_filter: date_filter)
  end

  let(:q) { "Soap" }
  let(:category) { nil }
  let(:date_from_year) { 2021 }
  let(:date_from_month) { "6" }
  let(:date_from_day) { "10" }
  let(:date_to_year) { 2021 }
  let(:date_to_month) { "6" }
  let(:date_to_day) { "15" }
  let(:date_exact_year) { "2021" }
  let(:date_exact_month) { "6" }
  let(:date_exact_day) { "13" }
  let(:date_filter) { nil }

  let(:date_from) do
    {
      day: date_from_day,
      month: date_from_month,
      year: date_from_year,
    }
  end

  let(:date_to) do
    {
      day: date_to_day,
      month: date_to_month,
      year: date_to_year,
    }
  end

  let(:date_exact) do
    {
      day: date_exact_day,
      month: date_exact_month,
      year: date_exact_year,
    }
  end

  describe "form behaviour" do
    context "when form fields are incorrect" do
      let(:date_exact_year) { "foo" }
      let(:date_exact_month) { "bar" }
      let(:date_exact_day) { "baz" }

      it "keeps year" do
        expect(form.date_exact.year).to eq "foo"
      end

      it "keeps month" do
        expect(form.date_exact.month).to eq "bar"
      end

      it "keeps day" do
        expect(form.date_exact.day).to eq "baz"
      end
    end
  end

  describe "#date_to_for_search" do
    context "when using range" do
      let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_RANGE }

      context "when date_to is invalid" do
        let(:date_to_month) { nil }

        it "is nil" do
          expect(form.date_to_for_search).to eq nil
        end
      end

      context "when date_to is empty" do
        let(:date_to) { nil }

        it "is nil" do
          expect(form.date_to_for_search).to eq nil
        end
      end

      context "when using date range" do
        it "is returned properly" do
          expect(form.date_to_for_search).to eq Date.new(2021, 6, 15)
        end
      end
    end

    context "when using exact date" do
      let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_EXACT }

      it "is returned properly" do
        expect(form.date_to_for_search).to eq Date.new(2021, 6, 13)
      end

      context "when date_exact is invalid" do
        let(:date_exact_month) { nil }

        it "is nil" do
          expect(form.date_to_for_search).to eq nil
        end
      end

      context "when date_exact is empty" do
        let(:date_exact) { nil }

        it "is nil" do
          expect(form.date_to_for_search).to eq nil
        end
      end
    end
  end

  describe "#date_from_for_search" do
    context "when using range" do
      let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_RANGE }

      context "when date_from is invalid" do
        let(:date_from_month) { nil }

        it "is nil" do
          expect(form.date_from_for_search).to eq nil
        end
      end

      context "when date_from is empty" do
        let(:date_from) { nil }

        it "is nil" do
          expect(form.date_from_for_search).to eq nil
        end
      end

      context "when using date range" do
        it "is returned properly" do
          expect(form.date_from_for_search).to eq Date.new(2021, 6, 10)
        end
      end
    end

    context "when using exact date" do
      let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_EXACT }

      it "is returned properly" do
        expect(form.date_from_for_search).to eq Date.new(2021, 6, 13)
      end

      context "when date_exact is invalid" do
        let(:date_exact_month) { nil }

        it "is nil" do
          expect(form.date_from_for_search).to eq nil
        end
      end

      context "when date_exact is empty" do
        let(:date_exact) { nil }

        it "is nil" do
          expect(form.date_from_for_search).to eq nil
        end
      end
    end
  end

  describe "validations" do
    before { form.valid? }

    context "when dates are correct" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when all date fields are blank" do
      context "when using date range" do
        let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_RANGE }

        let(:date_from_year) { nil }
        let(:date_from_month) { nil }
        let(:date_from_day) { nil }
        let(:date_to_year) { nil }
        let(:date_to_month) { nil }
        let(:date_to_day) { nil }

        it "is valid" do
          expect(form).not_to be_valid
        end

        context "when any field is present" do
          let(:date_from_day) { "12" }

          it "is invalid" do
            expect(form).not_to be_valid
          end
        end
      end

      context "when using date exact" do
        let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_EXACT }

        let(:date_exact_year) { "" }
        let(:date_exact_month) { "" }
        let(:date_exact_day) { "" }

        context "when all fields are empty" do
          it "is valid" do
            expect(form).not_to be_valid
          end
        end

        context "when any field is present" do
          let(:date_exact_day) { "12" }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors.count).to eq 1
          end
        end
      end
    end

    shared_examples_for "date validation with missing field" do
      it "has error" do
        expect(form.errors[field]).to be_present
      end
    end

    context "when using exact date" do
      let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_EXACT }
      let(:field)       { :date_exact }

      context "when year is missing" do
        include_examples "date validation with missing field" do
          let(:date_exact_year) { nil }
        end
      end

      context "when month is missing" do
        include_examples "date validation with missing field" do
          let(:date_exact_month) { nil }
        end
      end

      context "when day is missing" do
        include_examples "date validation with missing field" do
          let(:date_exact_day) { nil }
        end
      end

      context "when month is incorrect" do
        include_examples "date validation with missing field" do
          let(:date_exact_month) { "13" }
        end
      end

      context "when day is incorrect" do
        include_examples "date validation with missing field" do
          let(:date_exact_day) { "32" }
        end
      end
    end

    context "when using from date" do
      let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_RANGE }
      let(:field)       { :date_from }

      context "when year is missing" do
        include_examples "date validation with missing field" do
          let(:date_from_year) { nil }
        end
      end

      context "when month is missing" do
        include_examples "date validation with missing field" do
          let(:date_from_month) { nil }
        end
      end

      context "when day is missing" do
        include_examples "date validation with missing field" do
          let(:date_from_day) { nil }
        end
      end

      context "when month is incorrect" do
        include_examples "date validation with missing field" do
          let(:date_from_month) { "13" }
        end
      end

      context "when day is incorrect" do
        include_examples "date validation with missing field" do
          let(:date_from_day) { "32" }
        end
      end
    end

    context "when using to date" do
      let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_RANGE }
      let(:field)       { :date_to }

      context "when year is missing" do
        include_examples "date validation with missing field" do
          let(:date_to_year) { nil }
        end
      end

      context "when month is missing" do
        include_examples "date validation with missing field" do
          let(:date_to_month) { nil }
        end
      end

      context "when day is missing" do
        include_examples "date validation with missing field" do
          let(:date_to_day) { nil }
        end
      end

      context "when month is incorrect" do
        include_examples "date validation with missing field" do
          let(:date_to_month) { "13" }
        end
      end

      context "when day is incorrect" do
        include_examples "date validation with missing field" do
          let(:date_to_day) { "32" }
        end
      end
    end

    context "when from date is later than to date" do
      let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_RANGE }

      let(:date_from_day) { "18" }

      it "has error" do
        expect(form.errors[:date_to]).to be_present
      end
    end

    context "when from date is equal than to date" do
      let(:date_filter) { NotificationSearchForm::FILTER_BY_DATE_RANGE }

      let(:date_from_day) { date_to_day }

      it "has no error" do
        expect(form.errors[:date_to]).to be_blank
      end
    end
  end
end
