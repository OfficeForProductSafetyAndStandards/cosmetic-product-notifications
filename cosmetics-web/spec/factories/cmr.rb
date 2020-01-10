FactoryBot.define do
  factory :cmr do
    component
    name { "Test CMR" }
    cas_number { "1234567" }
    ec_number { "1234567" }
  end
end
