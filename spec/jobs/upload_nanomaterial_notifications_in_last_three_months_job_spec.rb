require "rails_helper"

RSpec.describe UploadNanomaterialNotificationsInLastThreeMonthsJob, :with_stubbed_antivirus do
  include_examples "Active Storage Upload jobs tests"

  # rubocop:disable RSpec/ExampleLength
  # rubocop:disable Style/TrailingCommaInArguments
  it "generates a CSV containing all submitted nanomaterials in last three months data" do
    travel_to Time.zone.local(2022, 3, 12, 12, 0, 0) do
      rp = create(:responsible_person, :with_a_contact_person, name: "Soaps LTD")
      # Unsubmitted won't be exported into the CSV
      create(:nanomaterial_notification, :not_submitted, responsible_person: rp, name: "Unsubmitted")
      create(:nanomaterial_notification, responsible_person: rp, name: "Zinc oxide", submitted_at: 4.months.ago)
      nano = create(:nanomaterial_notification,
                    responsible_person: rp,
                    name: "Zinc Peroxide",
                    eu_notified: true,
                    notified_to_eu_on: Date.new(2021, 3, 12),
                    submitted_at: Time.zone.now + 1)

      described_class.perform_now

      file = ActiveStorage::Blob.find_by(filename: described_class.file_name)
      file.open do |f|
        expect(f.read).to eq(
          <<~CSV
            Responsible Person,Contact person email address,UKN number,Date nanomaterial notification was submitted,Name of the nanomaterial,Was the EU notified about test on CPNP before 1 January 2021?,Date EU notified on
            Soaps LTD,contact.person@example.com,#{nano.id},2022-03-12,Zinc Peroxide,true,2021-03-12
          CSV
        )
      end
    end
  end
  # rubocop:enable Style/TrailingCommaInArguments
  # rubocop:enable RSpec/ExampleLength
end
