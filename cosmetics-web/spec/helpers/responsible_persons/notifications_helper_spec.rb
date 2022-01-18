require "rails_helper"

describe ResponsiblePersons::NotificationsHelper do
  let(:view_class) do
    Class.new do
      include ResponsiblePersons::NotificationsHelper
      include DateHelper
    end
  end

  describe "#notification_summary_references_rows" do
    subject(:summary_references_rows) { view_class.new.notification_summary_references_rows(notification) }

    let(:notification) do
      build_stubbed(:notification,
                    :registered,
                    reference_number: "60162968",
                    cpnp_reference: "3796528",
                    cpnp_notification_date: Time.zone.parse("2019-10-04T17:10Z"),
                    notification_complete_at: Time.zone.parse("2021-05-03T12:08Z"))
    end

    it "contains rows for reference number, CPNP reference, CPNP notification date and the completion date" do
      expect(summary_references_rows).to eq([
        { key: { html: "<abbr>UK</abbr> cosmetic product number" }, value: { text: "UKCP-60162968" } },
        { key: { html: "<abbr>EU</abbr> reference number" }, value: { text: "3796528" } },
        { key: { html: "First notified in the <abbr>EU</abbr>" }, value: { text: "4 October 2019" } },
        { key: { html: "<abbr>UK</abbr> notified" }, value: { text: "3 May 2021" } },
      ])
    end

    it "does not include a row for CPNP reference if it is not present" do
      notification.cpnp_reference = nil
      expect(summary_references_rows).to eq([
        { key: { html: "<abbr>UK</abbr> cosmetic product number" }, value: { text: "UKCP-60162968" } },
        { key: { html: "First notified in the <abbr>EU</abbr>" }, value: { text: "4 October 2019" } },
        { key: { html: "<abbr>UK</abbr> notified" }, value: { text: "3 May 2021" } },
      ])
    end

    it "does not include a row for CPNP notification date if it is not present" do
      notification.cpnp_notification_date = nil
      expect(summary_references_rows).to eq([
        { key: { html: "<abbr>UK</abbr> cosmetic product number" }, value: { text: "UKCP-60162968" } },
        { key: { html: "<abbr>EU</abbr> reference number" }, value: { text: "3796528" } },
        { key: { html: "<abbr>UK</abbr> notified" }, value: { text: "3 May 2021" } },
      ])
    end

    it "does not include a row for notification completion date if it is not present" do
      notification.notification_complete_at = nil
      expect(summary_references_rows).to eq([
        { key: { html: "<abbr>UK</abbr> cosmetic product number" }, value: { text: "UKCP-60162968" } },
        { key: { html: "<abbr>EU</abbr> reference number" }, value: { text: "3796528" } },
        { key: { html: "First notified in the <abbr>EU</abbr>" }, value: { text: "4 October 2019" } },
      ])
    end
  end
end
