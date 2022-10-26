require "rails_helper"

RSpec.describe FileAntivirusCheckable, type: :model do
  let(:attachment_stub) { instance_double(ActiveStorage::Attachment) }
  let(:file_metadata) { {} }
  let(:file_stub) { double("File Stub", attachment: attachment_stub, metadata: file_metadata) } # rubocop:disable RSpec/VerifiedDoubles
  let(:dummy_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes
      include FileAntivirusCheckable

      attribute :file

      def initialize(file)
        super
        @file = file
      end

      def self.name
        "DummyClass"
      end
    end
  end

  let(:dummy) { dummy_class.new(file: file_stub) }

  describe "#file_exists?" do
    it "returns true when image upload contains an attachment" do
      allow(file_stub).to receive(:attachment).and_return(attachment_stub)
      expect(dummy.file_exists?).to eq true
    end

    it "returns false when image upload does not contain an attachment" do
      allow(file_stub).to receive(:attachment).and_return(nil)
      expect(dummy.file_exists?).to eq false
    end
  end

  describe "#passed_antivirus_check?" do
    context "when image upload contains a file" do
      context "when the antivirus is disabled" do
        before { stub_const("ENV", { "ANTIVIRUS_ENABLED" => "false" }) }

        it { expect(dummy.passed_antivirus_check?).to eq true }
      end

      context "with the antivirus enabled" do
        before { stub_const("ENV", { "ANTIVIRUS_ENABLED" => "true" }) }

        context "with the file metadata marked as safe" do
          let(:file_metadata) { { "safe" => true } }

          it { expect(dummy.passed_antivirus_check?).to eq true }
        end

        context "with the file metadata marked as not safe" do
          let(:file_metadata) { { "safe" => false } }

          it { expect(dummy.passed_antivirus_check?).to eq false }
        end

        context "without safety information in the file metadata" do
          let(:file_metadata) { {} }

          it { expect(dummy.passed_antivirus_check?).to eq false }
        end
      end
    end

    context "when the instance does not contain a file" do
      let(:attachment) {}

      it { expect(dummy.passed_antivirus_check?).to eq false }
    end
  end

  describe "#pending_antivirus_check?" do
    before do
      allow(dummy).to receive(:file).and_return(file_stub)
    end

    context "when image upload contains a file" do
      context "when the antivirus is disabled" do
        before { stub_const("ENV", { "ANTIVIRUS_ENABLED" => "false" }) }

        it { expect(dummy.pending_antivirus_check?).to eq false }
      end

      context "with the antivirus enabled" do
        before { stub_const("ENV", { "ANTIVIRUS_ENABLED" => "true" }) }

        context "with the file metadata marked as safe" do
          let(:file_metadata) { { "safe" => true } }

          it { expect(dummy.pending_antivirus_check?).to eq false }
        end

        context "with the file metadata marked as not safe" do
          let(:file_metadata) { { "safe" => false } }

          it { expect(dummy.pending_antivirus_check?).to eq false }
        end

        context "without safety information in the file metadata" do
          let(:file_metadata) { {} }

          it { expect(dummy.pending_antivirus_check?).to eq true }
        end
      end
    end

    context "when instance does not contain a file" do
      let(:attachment) {}

      it { expect(dummy.passed_antivirus_check?).to eq false }
    end
  end

  describe "#failed_antivirus_check?" do
    context "when image upload contains a file" do
      context "when the antivirus is disabled" do
        before { stub_const("ENV", { "ANTIVIRUS_ENABLED" => "false" }) }

        it { expect(dummy.failed_antivirus_check?).to eq false }
      end

      context "with the antivirus enabled" do
        before { stub_const("ENV", { "ANTIVIRUS_ENABLED" => "true" }) }

        context "with the file metadata marked as safe" do
          let(:file_metadata) { { "safe" => true } }

          it { expect(dummy.failed_antivirus_check?).to eq false }
        end

        context "with the file metadata marked as not safe" do
          let(:file_metadata) { { "safe" => false } }

          it { expect(dummy.failed_antivirus_check?).to eq true }
        end

        context "without safety information in the file metadata" do
          let(:file_metadata) { {} }

          it { expect(dummy.failed_antivirus_check?).to eq false }
        end
      end
    end

    context "when the instance does not contain a file" do
      let(:attachment) {}

      it { expect(dummy.failed_antivirus_check?).to eq false }
    end
  end
end
