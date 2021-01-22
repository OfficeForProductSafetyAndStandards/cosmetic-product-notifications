FactoryBot.define do
  factory :notification_delete_log do
    submit_user_id { "" }
    name { "MyString" }
    responsible_person_id { 1 }
  end
end
