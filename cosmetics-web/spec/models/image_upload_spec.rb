require "rails_helper"

RSpec.describe ImageUpload, type: :model do
  let(:image_upload) { described_class.create }
  let(:file) { fixture_file_upload("/testImage.png", "image/png") }

  before do
    allow(described_class).to receive(:max_file_size).and_return(10)
  end

  after do
    allow(described_class).to receive(:max_file_size).and_call_original
  end

  describe "image validation", :with_stubbed_antivirus do
    it "adds an error if the file is above the allowed filesize" do
      image_upload.file.attach(file)
      image_upload.save
      expect(image_upload.errors[:file]).to include("must be smaller than 0MB")
    end
  end
end
