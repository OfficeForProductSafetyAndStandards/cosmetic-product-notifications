FactoryBot.define do
  factory :nano_material do
    sequence(:inci_name) { |n| "Nano #{n}" }
    notification

    trait :standard do
      purposes { [NanoMaterialPurposes.standard.sample.name] }
    end

    trait :non_standard do
      inci_name { nil }
      purposes { [NanoMaterialPurposes.other.name] }
      nanomaterial_notification { association :nanomaterial_notification, responsible_person: notification.responsible_person }
    end

    trait :toxicology_notified do
      confirm_toxicology_notified { "yes" }
    end

    trait :skip_validations do
      to_create { |instance| instance.save(validate: false) }
    end

    factory :nano_material_standard, traits: %i[standard]
    factory :nano_material_non_standard, traits: %i[non_standard]
  end
end
