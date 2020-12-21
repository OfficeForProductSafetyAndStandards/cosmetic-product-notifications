require "rails_helper"

RSpec.describe ImageUpload, type: :model do
  let(:image_upload) { described_class.new }
  let(:attachment) { fixture_file_upload("/testImage.png", "image/png") }
  let(:file_metadata) { {} }
  # rubocop:disable RSpec/VerifiedDoubles
  # ActiveStorage associations between ActiveStorage::Attached::One and ActiveStorage::Blob make this quite complex to stub with a verified stub.
  let(:file_stub) { double(attachment: attachment, metadata: file_metadata) }
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

  describe "#file_exists?" do
    it "returns true when image upload contains an attachment" do
      image_upload.file.attach(attachment)
      expect(image_upload.file_exists?).to eq true
    end

    it "returns false when image upload does not contain an attachment" do
      expect(image_upload.file_exists?).to eq false
    end
  end

  describe "#passed_antivirus_check?" do
    before do
      allow(image_upload).to receive(:file).and_return(file_stub)
    end

    context "when image upload contains a file" do
      let(:attachment) { fixture_file_upload("/testImage.png", "image/png") }

      context "when the antivirus is disabled" do
        before { stub_const("ENV", { "ANTIVIRUS_ENABLED" => "false" }) }

        it { expect(image_upload.passed_antivirus_check?).to eq true }
      end

      context "with the antivirus enabled" do
        before { stub_const("ENV", { "ANTIVIRUS_ENABLED" => "true" }) }

        context "with the file metadata is marked as safe" do
          let(:file_metadata) { { "safe" => true } }

          it { expect(image_upload.passed_antivirus_check?).to eq true }
        end

        context "with the file metadata is marked as not safe" do
          let(:file_metadata) { { "safe" => false } }

          it { expect(image_upload.passed_antivirus_check?).to eq false }
        end

        context "with the file metadata does not have safety information" do
          let(:file_metadata) { {} }

          it { expect(image_upload.passed_antivirus_check?).to eq false }
        end
      end
    end

    context "when image upload does not contain a file" do
      let(:attachment) {}

      it { expect(image_upload.passed_antivirus_check?).to eq false }
    end
  end

  describe "#pending_antivirus_check?" do
    before do
      allow(image_upload).to receive(:file).and_return(file_stub)
    end

    context "when image upload contains a file" do
      let(:attachment) { fixture_file_upload("/testImage.png", "image/png") }

      context "when the antivirus is disabled" do
        before { stub_const("ENV", { "ANTIVIRUS_ENABLED" => "false" }) }

        it { expect(image_upload.pending_antivirus_check?).to eq false }
      end

      context "with the antivirus enabled" do
        before { stub_const("ENV", { "ANTIVIRUS_ENABLED" => "true" }) }

        context "with the file metadata is marked as safe" do
          let(:file_metadata) { { "safe" => true } }

          it { expect(image_upload.pending_antivirus_check?).to eq false }
        end

        context "with the file metadata is marked as not safe" do
          let(:file_metadata) { { "safe" => false } }

          it { expect(image_upload.pending_antivirus_check?).to eq false }
        end

        context "with the file metadata does not have safety information" do
          let(:file_metadata) { {} }

          it { expect(image_upload.pending_antivirus_check?).to eq true }
        end
      end
    end

    context "when image upload does not contain a file" do
      let(:attachment) {}

      it { expect(image_upload.passed_antivirus_check?).to eq false }
    end
  end

  describe "#failed_antivirus_check?" do
    before do
      allow(image_upload).to receive(:file).and_return(file_stub)
    end

    context "when image upload contains a file" do
      let(:attachment) { fixture_file_upload("/testImage.png", "image/png") }

      context "when the antivirus is disabled" do
        before { stub_const("ENV", { "ANTIVIRUS_ENABLED" => "false" }) }

        it { expect(image_upload.failed_antivirus_check?).to eq false }
      end

      context "with the antivirus enabled" do
        before { stub_const("ENV", { "ANTIVIRUS_ENABLED" => "true" }) }

        context "with the file metadata is marked as safe" do
          let(:file_metadata) { { "safe" => true } }

          it { expect(image_upload.failed_antivirus_check?).to eq false }
        end

        context "with the file metadata is marked as not safe" do
          let(:file_metadata) { { "safe" => false } }

          it { expect(image_upload.failed_antivirus_check?).to eq true }
        end

        context "with the file metadata does not have safety information" do
          let(:file_metadata) { {} }

          it { expect(image_upload.failed_antivirus_check?).to eq false }
        end
      end
    end

    context "when image upload does not contain a file" do
      let(:attachment) {}

      it { expect(image_upload.failed_antivirus_check?).to eq false }
    end
  end
end
