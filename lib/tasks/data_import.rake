require "net/http"
require "json"

namespace :data_import do
  desc "Import data from the Open Product Database"
  task ops: :environment do
    puts number_of_hits
    # TODO: Change the number of rows to be the number of hits
    # We may need to paginate this as it is almost 1 million!
    uri = URI("https://pod.opendatasoft.com/api/records/1.0/search/?dataset=pod_gtin&lang=en&rows=100")
    response = Net::HTTP.get(uri)
    json_response = JSON.parse(response)
    json_response["records"].each do |product|
      Product.create(
        gtin: product["fields"]["gtin_cd"],
        name: product["fields"]["gtin_nm"],
        purchase_url: product["fields"]["brand_link"],
        brand: product["fields"]["brand_nm"]
      )
    end
  end

  def number_of_hits
    uri = URI("https://pod.opendatasoft.com/api/records/1.0/search/?dataset=pod_gtin&lang=en&rows=0")
    response = Net::HTTP.get(uri)
    json_response = JSON.parse(response)
    json_response["nhits"]
  end
end
