require "rails_helper"

RSpec.describe ImageUpload, type: :model do
  let(:image_upload) { described_class.new }
  let(:attachment) { fixture_file_upload("/testImage.png", "image/png") }
  let(:file_metadata) { {} }
  # rubocop:disable RSpec/VerifiedDoubles
  # ActiveStorage associations between ActiveStorage::Attached::One and ActiveStorage::Blob make this quite complex to stub with a verified stub.
  let(:file_stub) { double(attachment:, metadata: file_metadata) }
  # rubocop:enable RSpec/VerifiedDoubles

  describe "image validation", :with_stubbed_antivirus do
    context "when the file is above the allowed filesize" do
      before do
        allow(described_class).to receive(:max_file_size).and_return(10)
      end

      it "adds an error" do
        image_upload.file.attach(attachment)
        image_upload.validate
        expect(image_upload.errors[:file]).to include("must be smaller than 0MB")
      end
    end
  end
end
