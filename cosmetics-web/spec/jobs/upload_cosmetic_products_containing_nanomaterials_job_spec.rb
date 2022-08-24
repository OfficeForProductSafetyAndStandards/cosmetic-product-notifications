require "rails_helper"

RSpec.describe UploadCosmeticProductsContainingNanomaterialsJob do
  include_examples "Active Storage Upload jobs tests"

  # rubocop:disable RSpec/ExampleLength
  # rubocop:disable Style/TrailingCommaInArguments
  it "generates a CSV containing all the products with nanomaterials" do
    travel_to Time.zone.local(2022, 3, 12, 12, 0, 0) do
      rp = create(:responsible_person, :with_a_contact_person, name: "Soaps LTD")
      nano_elem = create(:nano_element, inci_name: "Zinc oxide", purposes: %w[colorant preservative])
      nano = create(:nano_material, nano_elements: [nano_elem])
      create(:notification,
             :with_nano_material,
             responsible_person: rp,
             product_name: "Soapy Soaps",
             reference_number: 123_456,
             nano_materials: [nano],
             notification_complete_at: 1.day.ago)

      described_class.perform_now

      file = ActiveStorage::Blob.find_by(filename: described_class.file_name)
      file.open do |f|
        expect(f.read).to eq(
          <<~CSV
            Responsible Person,Cosmetic product name,Date cosmetic product was notified,UKCP number,INCI name,Nanomaterial purposes
            Soaps LTD,Soapy Soaps,2022-03-11,123456,Zinc oxide,"{colorant,preservative}"
          CSV
        )
      end
    end
  end
  # rubocop:enable Style/TrailingCommaInArguments
  # rubocop:enable RSpec/ExampleLength
end
