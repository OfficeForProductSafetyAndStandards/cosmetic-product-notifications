require "rails_helper"

RSpec.describe SupportPortal::HistoryHelper, type: :helper do
  describe "#display_responsible_person_action_details" do
    describe "#responsible_person_business_type" do
      it "returns formatted business type for known types" do
        expect(helper.responsible_person_business_type("limited_company")).to eq("Limited Company")
        expect(helper.responsible_person_business_type("sole_trader")).to eq("Sole Trader")
      end

      it "handles unknown business types" do
        expect(helper.responsible_person_business_type("unknown_type")).to eq("Unknown Type")
      end

      it "handles blank input" do
        expect(helper.responsible_person_business_type(nil)).to eq("")
        expect(helper.responsible_person_business_type("")).to eq("")
      end
    end

    context "when handling address changes" do
      let(:complete_address_changes) do
        {
          "address_line_1" => ["Old Street 1", "New Street 1"],
          "address_line_2" => ["Old Street 2", "New Street 2"],
          "city" => ["Old City", "New City"],
          "county" => ["Old County", "New County"],
          "postal_code" => ["Old Code", "New Code"],
        }
      end

      let(:complete_address_output) do
        [
          "Change from: Old Street 1<br>To: New Street 1",
          "Change from: Old Street 2<br>To: New Street 2",
          "Change from: Old City<br>To: New City",
          "Change from: Old County<br>To: New County",
          "Change from: Old Code<br>To: New Code",
        ].join("<br>")
      end

      let(:partial_address_changes) do
        {
          "address_line_1" => ["Old Street 1", "New Street 1"],
          "city" => ["Old City", "New City"],
        }
      end

      let(:partial_address_output) do
        [
          "Change from: Old Street 1<br>To: New Street 1",
          "Change from: Old City<br>To: New City",
        ].join("<br>")
      end

      let(:empty_address_changes) do
        {
          "address_line_1" => ["", "New Street 1"],
          "address_line_2" => [nil, "New Street 2"],
        }
      end

      let(:empty_address_output) do
        [
          "Change from: <em>Empty</em><br>To: New Street 1",
          "Change from: <em>Empty</em><br>To: New Street 2",
        ].join("<br>")
      end

      it "handles complete address changes" do
        expect(helper.display_responsible_person_action_details(complete_address_changes))
          .to eq(complete_address_output)
      end

      it "handles partial address changes" do
        expect(helper.display_responsible_person_action_details(partial_address_changes))
          .to eq(partial_address_output)
      end

      it "handles empty values in address changes" do
        expect(helper.display_responsible_person_action_details(empty_address_changes))
          .to eq(empty_address_output)
      end
    end

    context "when handling account type changes" do
      let(:business_type_changes) do
        {
          "account_type" => %w[limited_company sole_trader],
        }
      end

      it "handles business type changes" do
        expect(helper.display_responsible_person_action_details(business_type_changes))
          .to eq("Change from: Limited Company<br>To: Sole Trader")
      end
    end

    context "when handling invalid changes" do
      let(:changes_with_nil) do
        {
          "address_line_1" => nil,
          "city" => ["Old City", "New City"],
        }
      end

      let(:empty_changes) do
        {
          "address_line_1" => [],
        }
      end

      it "skips nil changes" do
        expect(helper.display_responsible_person_action_details(changes_with_nil))
          .to eq("Change from: Old City<br>To: New City")
      end

      it "handles empty change arrays" do
        expect(helper.display_responsible_person_action_details(empty_changes))
          .to eq("")
      end
    end
  end
end
