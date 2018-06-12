require "net/http"
require "json"

namespace :data_import do
  desc "Import data from the Open Product Database"
  task opd: :environment do
    max_rows = 100
    hits = number_of_hits
    Product.delete_all
    (0..(hits / max_rows).ceil).each do |i|
      products = fetch_products(i * max_rows, max_rows)
      create_products products
    end
  end
end

def create_products(products)
  products.each do |product|
    fields = product["record"]["fields"]
    Product.create(
      gtin: fields["gtin_cd"],
      name: fields["gtin_nm"],
      purchase_url: fields["brand_link"],
      brand: fields["brand_nm"],
      image_url: fields["gtin_img"]
    )
  end
end

def fetch_products(start, rows)
  puts "Fetching rows #{start} to #{start + rows}"
  uri = URI("https://pod.opendatasoft.com/api/v2/catalog/datasets/pod_gtin/records?start=#{start}&rows=#{rows}")
  response = JSON.parse(Net::HTTP.get(uri))
  puts "Data parsed"
  response["records"]
end

def number_of_hits
  uri = URI("https://pod.opendatasoft.com/api/v2/catalog/datasets/pod_gtin/records?rows=0")
  response = Net::HTTP.get(uri)
  json_response = JSON.parse(response)
  json_response["total_count"]
end
