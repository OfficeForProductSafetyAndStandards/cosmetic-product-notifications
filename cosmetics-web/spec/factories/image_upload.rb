FactoryBot.define do
  factory :image_upload do
    notification
    file { Rack::Test::UploadedFile.new("spec/fixtures/testPdf.pdf", "image/png") }

    trait :uploaded_and_virus_scanned do
      after :create do |image_upload|
        image_upload.file.metadata["safe"] = true
      end
    end
  end
end
