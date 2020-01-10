FactoryBot.define do
  factory :nanomaterial_notification do
    responsible_person
    name { "Zinc oxide" }
    user_id { "123-456-abc" }

    trait :submittable do
      eu_notified { false }
      file { Rack::Test::UploadedFile.new("spec/fixtures/testPdf.pdf", "image/png") }
    end

    trait :not_submitted do
      submitted_at { nil }
    end

    trait :submitted do
      submitted_at { 1.hour.ago }
    end
  end
end
