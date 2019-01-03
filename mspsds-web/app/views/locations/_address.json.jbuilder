json.extract! address, :id, :business_id, :name, :address, :phone_number, :locality,
              :country, :postal_code, :created_at, :updated_at
json.url address_url(address, format: :json)
