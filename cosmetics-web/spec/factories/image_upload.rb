FactoryBot.define do
  factory :image_upload do
    notification
    file { Rack::Test::UploadedFile.new("spec/fixtures/files/testPdf.pdf", "image/png") }

    trait :uploaded_and_virus_scanned do
      after(:stub, :create) do |image_upload|
        image_upload.file.metadata["safe"] = true
      end
    end

    trait :uploaded_and_virus_identified do
      after(:stub, :create) do |image_upload|
        image_upload.file.metadata["safe"] = false
      end
    end
  end
end
