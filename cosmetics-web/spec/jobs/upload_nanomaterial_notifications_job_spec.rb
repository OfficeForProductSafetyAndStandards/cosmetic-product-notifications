require "rails_helper"

RSpec.describe UploadNanomaterialNotificationsJob do
  it "uploads a CSV file" do
    expect { described_class.perform_now }.to change(ActiveStorage::Blob, :count).by(1)
    expect(ActiveStorage::Blob.last.filename).to eq(described_class::FILE_NAME)
  end

  # rubocop:disable RSpec/ExampleLength
  it "replaces the previous upload" do
    travel_to Time.zone.local(2022, 3, 12, 12, 0, 0) do
      described_class.perform_now
    end
    travel_to Time.zone.local(2022, 3, 13, 12, 0, 0) do
      uploads = ActiveStorage::Blob.where(filename: described_class::FILE_NAME)
      expect { described_class.perform_now }
        .to not_change(uploads, :count)
        .and change { uploads.last.created_at }.from(Time.zone.local(2022, 3, 12, 12, 0, 0))
                                               .to(Time.zone.local(2022, 3, 13, 12, 0, 0))
    end
  end
  # rubocop:enable RSpec/ExampleLength

  it "does not leave the CSV file in the app temp folder" do
    described_class.perform_now
    expect { File.open(described_class::FILE_PATH) }.to raise_error(Errno::ENOENT)
  end
end
