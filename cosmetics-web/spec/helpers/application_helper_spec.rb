require "rails_helper"

describe ApplicationHelper do
  describe "#error_summary" do
    let(:view_class) do
      Class.new do
        include ApplicationHelper
        include GovukDesignSystem::ErrorSummaryHelper
      end
    end

    let(:view) { view_class.new }
    let(:errors) do
      [
        OpenStruct.new(attribute: :name, message: "Name cannot be blank"),
        OpenStruct.new(attribute: :email, message: "Email cannot be blank"),
        OpenStruct.new(attribute: :mobile_number, message: "Mobile number is too short"),
      ]
    end

    before { allow(view).to receive(:govukErrorSummary) }

    def expect_error_summary_for(formatted_errors)
      expect(view).to have_received(:govukErrorSummary).with(
        titleText: "There is a problem",
        errorList: formatted_errors,
      )
    end

    context "when no attributes order is given" do
      it "calls for the error summary with a formatted unordered list of errors" do
        view.error_summary(errors)
        expect_error_summary_for([{ text: "Name cannot be blank", href: "#name" },
                                  { text: "Email cannot be blank", href: "#email" },
                                  { text: "Mobile number is too short", href: "#mobile_number" }])
      end
    end

    context "when providing error mapping to other attribute" do
      it "errors for the key on the mapping point to the value of the mapping" do
        view.error_summary(errors, map_errors: { name: :email })
        expect_error_summary_for([{ text: "Name cannot be blank", href: "#email" },
                                  { text: "Email cannot be blank", href: "#email" },
                                  { text: "Mobile number is too short", href: "#mobile_number" }])
      end
    end

    context "when providing a list with attributes order" do
      context "with all the attributes defined in the order" do
        let(:order) { %i[mobile_number email name] }

        it "generates the error summary with an ordered and formatted list of errors" do
          view.error_summary(errors, order)
          expect_error_summary_for([{ text: "Mobile number is too short", href: "#mobile_number" },
                                    { text: "Email cannot be blank", href: "#email" },
                                    { text: "Name cannot be blank", href: "#name" }])
        end
      end

      context "when some attribute is missing in the order" do
        let(:order) { %i[mobile_number name] }

        it "adds the attribute errors after the ordered ones" do
          view.error_summary(errors, order)
          expect_error_summary_for([{ text: "Mobile number is too short", href: "#mobile_number" },
                                    { text: "Name cannot be blank", href: "#name" },
                                    { text: "Email cannot be blank", href: "#email" }])
        end
      end

      context "when the order includes attributes without errors" do
        let(:order) { %i[bar name foo mobile_number email] }

        it "ignores them and respects the order for the attributes with errors" do
          view.error_summary(errors, order)
          expect_error_summary_for([{ text: "Name cannot be blank", href: "#name" },
                                    { text: "Mobile number is too short", href: "#mobile_number" },
                                    { text: "Email cannot be blank", href: "#email" }])
        end
      end
    end

    context "when an error is missing a message" do
      let(:errors) do
        [
          OpenStruct.new(attribute: :name, message: "Name cannot be blank"),
          OpenStruct.new(attribute: :email, message: ""),
          OpenStruct.new(attribute: :mobile_number, message: "   "),
          OpenStruct.new(attribute: :fax_number, message: nil),
        ]
      end

      it "does not display errors with nil or blank messages" do
        view.error_summary(errors)
        expect_error_summary_for([{ text: "Name cannot be blank", href: "#name" }])
      end
    end
  end
end
