require "net/http"
require "json"
require "open-uri"

namespace :data_import do
  desc "Import data from the Open Product Database"
  task opd: :environment do
    # -1 for rows means all data
    products = fetch_products(0, -1)
    create_products products
  end
end

def create_products(products)
  products.each do |product|
    Product.create(
      gtin: product["gtin_cd"],
      name: product["gtin_nm"],
      purchase_url: product["brand_link"],
      brand: product["brand_nm"],
      image_url: product["gtin_img"]
    )
  end
end

def fetch_products(start, rows)
  puts "Fetching data"
  uri = URI("https://pod.opendatasoft.com/api/v2/catalog/datasets/pod_gtin/exports/json?start=#{start}&rows=#{rows}")
  response = JSON.parse(Net::HTTP.get(uri))
  puts "Data parsed"
  response
end
