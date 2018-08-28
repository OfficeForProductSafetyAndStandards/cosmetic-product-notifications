json.extract! product, :id, :gtin, :name, :product_type, :description, :model, :source,
              :batch_number, :country_of_origin, :brand,
              :date_placed_on_market, :created_at, :updated_at
json.url product_url(product, format: :json)
