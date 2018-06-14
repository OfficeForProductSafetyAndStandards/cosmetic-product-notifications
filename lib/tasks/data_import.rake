require "net/http"
require "json"
require "open-uri"

namespace :data_import do
  desc "Import data from the Open Product Database"
  task opd: :environment do
    puts "Fetching #{number_of_hits} rows"
    products = fetch_products(0, -1)
    puts "Creating products"
    create_products products
    puts "Product creation complete"
  end
end

def create_products(products)
  products.each do |product|
    Product.create(
      gtin: product["gtin_cd"],
      name: product["gtin_nm"],
      purchase_url: product["brand_link"],
      brand: product["brand_nm"] && product["brand_nm"][0] || nil,
      image_url: product["gtin_img"]
    )
  end
end

# API supports only the first 10,000 rows paginated. Alternatively, you can get all data using
# rows = -1
def fetch_products(start, rows)
  puts "Fetching rows #{start} to #{start + rows}"
  uri = URI("https://pod.opendatasoft.com/api/v2/catalog/datasets/pod_gtin/exports/json"\
    "?where=NOT%20%22Food%20-%20Beverage%20-%20Tobacco%22&start=#{start}&rows=#{rows}")
  JSON.parse(Net::HTTP.get(uri))
end

def number_of_hits
  uri = URI("https://pod.opendatasoft.com/api/v2/catalog/datasets/pod_gtin/records"\
    "?where=NOT%20%22Food%20-%20Beverage%20-%20Tobacco%22&rows=0")
  response = Net::HTTP.get(uri)
  json_response = JSON.parse(response)
  json_response["total_count"]
end
