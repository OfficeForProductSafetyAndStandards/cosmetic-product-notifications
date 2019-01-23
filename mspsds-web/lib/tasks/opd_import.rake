require "net/http"
require "json"
require "open-uri"

namespace :data_import do
  desc "Import data from the Open Product Database"
  task opd: :environment do
    page_size = 1000
    # Using pagination, the API only allows the first 10000 entries
    # hits = number_of_hits
    hits = 9_000
    puts "Fetching #{hits} rows"
    (0..((hits / page_size).ceil - 1)).each do |i|
      products = fetch_products(i * page_size, page_size)
      create_products products
    end
  end
end

def create_products(products)
  products.each do |product|
    Product.create(
      product_code: product["gtin_cd"],
      name: product["gtin_nm"],
      brand: product["brand_nm"] && product["brand_nm"][0] || nil,
      source: "Imported from the Open Product Database"
    )
  end
end

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
