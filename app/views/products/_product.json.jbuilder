json.extract! product, :id, :gtin, :name, :description, :model, :mpn,
              :batch_number, :purchase_url, :brand, :created_at, :updated_at
json.url product_url(product, format: :json)
