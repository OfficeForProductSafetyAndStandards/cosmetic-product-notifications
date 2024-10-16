FactoryBot.define do
  factory :cmr do
    component
    name { "Test CMR" }
    cas_number { "1234-56-7" }
    ec_number { "123-456-7" }
  end
end
