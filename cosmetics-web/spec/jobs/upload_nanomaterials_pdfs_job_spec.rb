require "rails_helper"
require "zip"

RSpec.describe UploadNanomaterialsPdfsJob, :with_stubbed_antivirus do
  include_examples "Active Storage Upload jobs tests"

  # rubocop:disable RSpec/ExampleLength
  # rubocop:disable RSpec/MultipleExpectations
  it "generates a ZIP containing all the nanomaterial notifications PDFs" do
    nano = create(:nanomaterial_notification, :submitted, name: "Zinc oxide")

    described_class.perform_now

    blob = ActiveStorage::Blob.find_by(filename: described_class.file_name)
    blob.open do |b|
      Zip::File.open(b) do |zip|
        zipped_files = zip.entries.map(&:name)
        expect(zipped_files).to eq(["UKN-#{nano.id}.pdf"]) # Correct file name
        zipped_file = zip.entries.first

        expect(zipped_file.size).to eq nano.file.open(&:size) # Same size as attachment

        zipped_file_hash = Digest::MD5.hexdigest(zipped_file.get_input_stream.read)
        nano_pdf_hash = nano.file.open { |f| Digest::MD5.hexdigest(f.read) } # Zipped PDF and Nanomaterial notification PDF are identical

        expect(zipped_file_hash).to eq(nano_pdf_hash)
      end
    end
  end
  # rubocop:enable RSpec/MultipleExpectations
  # rubocop:enable RSpec/ExampleLength
end
