json.extract! product, :id, :gtin, :name, :description, :model, :serial_number, :source,
              :batch_number, :manufacturer, :country_of_origin, :url_reference, :brand,
              :date_placed_on_market, :associated_parts, :created_at, :updated_at
json.url product_url(product, format: :json)
