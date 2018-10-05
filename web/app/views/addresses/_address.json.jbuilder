json.extract! address, :id, :business_id, :address_type, :line_1, :line_2, :locality,
              :country, :postal_code, :created_at, :updated_at
json.url address_url(address, format: :json)
