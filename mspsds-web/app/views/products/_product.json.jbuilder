json.extract! product, :id, :product_code, :name, :product_type, :category, :webpage, :description, :source,
              :batch_number, :country_of_origin,
              :date_placed_on_market, :created_at, :updated_at
json.url product_url(product, format: :json)
