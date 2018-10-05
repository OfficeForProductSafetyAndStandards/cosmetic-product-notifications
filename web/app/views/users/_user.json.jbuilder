json.extract! user, :id, :email, :created_at, :updated_at
json.url users_url(user, format: :json)
