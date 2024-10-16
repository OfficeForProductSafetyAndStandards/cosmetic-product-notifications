require "rails_helper"

RSpec.describe UploadNanomaterialNotificationsJob, :with_stubbed_antivirus do
  before do
    travel_to Time.zone.local(2022, 3, 12, 12, 0, 0)
    nano.save!
    nano2.save!
    unsubmitted_nano.save!
  end

  after do
    travel_back
  end

  let(:rp) do
    create(:responsible_person, :with_a_contact_person, name: "Soaps LTD")
  end

  let(:nano) do
    build(:nanomaterial_notification,
          responsible_person: rp,
          name: "Zinc oxide",
          submitted_at: 4.months.ago,
          eu_notified: false)
  end

  let(:nano2) do
    build(:nanomaterial_notification,
          responsible_person: rp,
          name: "Zinc Peroxide",
          eu_notified: true,
          notified_to_eu_on: Date.new(2021, 3, 12),
          submitted_at: Time.zone.now + 1)
  end

  let(:unsubmitted_nano) do
    # Unsubmitted nano that won't be exported into the CSV
    build(:nanomaterial_notification, :not_submitted, responsible_person: rp, name: "Unsubmitted")
  end

  let(:csv_contents) do
    <<~CSV
      Responsible Person,Contact person email address,UKN number,Date nanomaterial notification was submitted,Name of the nanomaterial,Was the EU notified about test on CPNP before 1 January 2021?,Date EU notified on
      Soaps LTD,contact.person@example.com,#{nano.id},2021-11-12,Zinc oxide,false,
      Soaps LTD,contact.person@example.com,#{nano2.id},2022-03-12,Zinc Peroxide,true,2021-03-12
    CSV
  end

  let(:csv_file_content) do
    ActiveStorage::Blob.find_by(filename: described_class.file_name).open(&:read)
  end

  include_examples "Active Storage Upload jobs tests"

  it "checks that all 3 nanomaterial notifications were created" do
    described_class.perform_now
    expect(NanomaterialNotification.all).to eq([nano, nano2, unsubmitted_nano])
  end

  it "generates a CSV containing the 2 submitted nanomaterials data" do
    described_class.perform_now
    expect(csv_file_content).to eq(csv_contents)
  end
end
