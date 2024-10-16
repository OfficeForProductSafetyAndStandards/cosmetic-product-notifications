FactoryBot.define do
  factory :notification_delete_log do
    submit_user_id { create(:user).id }
    notification_product_name { "Test Product" }
    responsible_person_id { create(:responsible_person).id }
    notification_created_at { "2023-08-01" }
    notification_updated_at { "2023-08-05" }
    cpnp_reference { "C123456789" }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
    reference_number { "R123456789" }
  end
end
