require "rails_helper"

RSpec.describe UploadCosmeticProductsContainingNanomaterialsJob do
  include_examples "Active Storage Upload jobs tests"

  # rubocop:disable RSpec/ExampleLength
  # rubocop:disable Style/TrailingCommaInArguments
  it "generates a CSV containing all the products with nanomaterials" do
    rp = create(:responsible_person, :with_a_contact_person, name: "Soaps LTD")
    notification = create(:notification, responsible_person: rp)
    nano = create(:nano_material, inci_name: "Zinc oxide", purposes: %w[colorant preservative])
    nano2 = create(:nano_material, inci_name: "Oxide zinc", purposes: %w[colorant preservative])
    nano3 = create(:nano_material, :non_standard, notification:)

    create(:notification,
           responsible_person: rp,
           product_name: "Soapy Soap",
           reference_number: 123_456,
           nano_materials: [nano],
           notification_complete_at: 1.day.ago)
    create(:notification,
           responsible_person: rp,
           product_name: "Creamy Cream",
           reference_number: 321_654,
           nano_materials: [nano2],
           notification_complete_at: 4.months.ago)
    create(:notification,
           responsible_person: rp,
           product_name: "Non standard",
           reference_number: 321_655,
           nano_materials: [nano3],
           notification_complete_at: 1.month.ago)

    described_class.perform_now

    file = ActiveStorage::Blob.find_by(filename: described_class.file_name)
    file.open do |f|
      expect(f.read).to eq(
        <<~CSV
          Responsible Person,Cosmetic product name,Date cosmetic product was notified,UKCP number,INCI name,Nanomaterial purposes,UKN number
          Soaps LTD,Creamy Cream,#{4.months.ago.to_date},321654,Oxide zinc,"{colorant,preservative}",
          Soaps LTD,Non standard,#{1.month.ago.to_date},321655,,{other},#{nano3.nanomaterial_notification_id}
          Soaps LTD,Soapy Soap,#{1.day.ago.to_date},123456,Zinc oxide,"{colorant,preservative}",
        CSV
      )
    end
  end
  # rubocop:enable Style/TrailingCommaInArguments
  # rubocop:enable RSpec/ExampleLength
end
