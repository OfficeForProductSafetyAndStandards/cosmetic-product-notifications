FactoryBot.define do
  factory :nano_material do
    inci_name { "Nano foo" }
    notification
  end

  trait :skip_validations do
    to_create { |instance| instance.save(validate: false) }
  end
end
