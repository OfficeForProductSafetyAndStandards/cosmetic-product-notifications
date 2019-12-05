FactoryBot.define do
  factory :image_upload do
    trait :uploaded_and_virus_scanned do
      after :create do |image_upload|
        file = fixture_file_upload(Rails.root.join("spec", "fixtures", "testImage.png"), "image/png")
        image_upload.file.attach(file)
        image_upload.file.metadata["safe"] = "true"
      end
    end
  end
end
