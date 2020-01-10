FactoryBot.define do
  factory :notification_file do
    responsible_person
    after :create do |notification_file, options|
      notification_file.name = options.uploaded_file.filename if notification_file.uploaded_file.attached?
    end
  end
end
