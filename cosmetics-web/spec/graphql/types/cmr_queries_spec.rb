require "rails_helper"

RSpec.describe Types::CmrQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  # Helper method to perform the GraphQL post request
  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "cmr query" do
    let(:cmr) { create(:cmr) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          cmr(id: $id) {
            id
            name
          }
        }
      GQL
    end

    it "returns a CMR by ID" do
      response_json = perform_post_query(query, { id: cmr.id })

      expect(response_json).to have_key("data")
      cmr_data = response_json["data"]["cmr"]

      expect(cmr_data["id"]).to eq(cmr.id.to_s)
    end

    it "returns error for non-existent CMR" do
      response_json = perform_post_query(query, { id: -1 })

      expect(response_json).to have_key("errors")
      expect(response_json["errors"].first["message"]).to eq("Couldn't find cmr with 'id' -1")
    end
  end

  describe "cmrs query" do
    let!(:recent_cmr) { create(:cmr, created_at: "2023-08-10", updated_at: "2023-08-15") }

    let(:query) do
      <<~GQL
        query($created_after: String, $first: Int) {
          cmrs(created_after: $created_after, first: $first) {
            edges {
              node {
                id
                name
              }
            }
            pageInfo {
              hasNextPage
            }
          }
        }
      GQL
    end

    context "when filtering CMRs" do
      let(:variables) { { created_after: "2023-08-05T00:00:00Z", first: 10 } }
      let(:response_json) { perform_post_query(query, variables) }

      it "returns the correct number of filtered CMRs" do
        expect(response_json).to have_key("data")
        data_edges = response_json["data"]["cmrs"]["edges"]

        expect(data_edges.size).to eq(1)
      end

      it "returns the correct CMR details" do
        data_edges = response_json["data"]["cmrs"]["edges"]
        expect(data_edges.first["node"]["id"]).to eq(recent_cmr.id.to_s)
        expect(data_edges.first["node"]["name"]).to eq(recent_cmr.name)
      end

      it "returns pagination information" do
        page_info = response_json["data"]["cmrs"]["pageInfo"]
        expect(page_info["hasNextPage"]).to be(false)
      end
    end
  end

  describe "total_cmr_count query" do
    let(:query) do
      <<~GQL
        query {
          total_cmr_count
        }
      GQL
    end

    it "returns total CMR count" do
      create_list(:cmr, 3) # Create the CMRs directly here

      response_json = perform_post_query(query)

      expect(response_json).to have_key("data")
      expect(response_json["data"]["total_cmr_count"]).to eq(3)
    end
  end
end
