require "rails_helper"

RSpec.describe Types::SearchHistoryQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  # Helper method to perform the GraphQL post request
  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "search_history query" do
    let(:search_history) { create(:search_history) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          search_history(id: $id) {
            id
            query
            results
            sort_by
            created_at
            updated_at
          }
        }
      GQL
    end

    def query_search_history_and_extract_data(id)
      response_json = perform_post_query(query, { id: })
      response_json["data"]["search_history"]
    end

    it "returns a SearchHistory by ID" do
      data = query_search_history_and_extract_data(search_history.id)
      expect(data).to have_key("id")
      expect(data["id"]).to eq(search_history.id.to_s)
    end

    it "returns the associated query" do
      data = query_search_history_and_extract_data(search_history.id)
      expect(data["query"]).to eq(search_history.query)
    end

    it "returns the associated results" do
      data = query_search_history_and_extract_data(search_history.id)
      expect(data["results"]).to eq(search_history.results)
    end

    it "returns created_at timestamp" do
      data = query_search_history_and_extract_data(search_history.id)
      expect(data["created_at"]).to eq(search_history.created_at.utc.iso8601)
    end

    it "returns updated_at timestamp" do
      data = query_search_history_and_extract_data(search_history.id)
      expect(data["updated_at"]).to eq(search_history.updated_at.utc.iso8601)
    end

    it "returns an error when SearchHistory not found" do
      response_json = perform_post_query(query, { id: -1 })
      expect(response_json).to have_key("errors")
      errors = response_json["errors"]
      expect(errors.first["message"]).to eq("Couldn't find search_history with 'id' -1")
    end
  end

  describe "search_histories query" do
    let!(:recent_search_history) { create(:search_history, created_at: "2024-08-10", updated_at: "2024-08-15") }
    let(:older_search_history) { create(:search_history, created_at: "2024-08-01", updated_at: "2024-08-05") }

    let(:query) do
      <<~GQL
        query($created_after: String, $updated_after: String, $first: Int) {
          search_histories(created_after: $created_after, updated_after: $updated_after, first: $first) {
            edges {
              node {
                id
                query
                results
                sort_by
                created_at
                updated_at
              }
              cursor
            }
            pageInfo {
              hasNextPage
              hasPreviousPage
              startCursor
              endCursor
            }
          }
        }
      GQL
    end

    def query_search_histories(created_after: nil, updated_after: nil, first: nil)
      perform_post_query(query, { created_after:, updated_after:, first: })
    end

    it "returns the total number of SearchHistories" do
      response_json = query_search_histories(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "search_histories", "edges").size).to eq(1)
    end

    it "returns the associated query for the first search history" do
      response_json = query_search_histories(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "search_histories", "edges").first["node"]["query"]).to eq(recent_search_history.query)
    end

    it "checks pagination hasNextPage is false" do
      response_json = query_search_histories(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "search_histories", "pageInfo")
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "checks pagination hasPreviousPage is false or nil" do
      response_json = query_search_histories(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "search_histories", "pageInfo")
      expect(page_info["hasPreviousPage"]).to be(false).or(be_nil)
    end

    it "checks pagination startCursor is not nil" do
      response_json = query_search_histories(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "search_histories", "pageInfo")
      expect(page_info["startCursor"]).not_to be_nil
    end

    it "checks pagination endCursor is not nil" do
      response_json = query_search_histories(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "search_histories", "pageInfo")
      expect(page_info["endCursor"]).not_to be_nil
    end
  end

  describe "total_search_histories_count query" do
    before do
      create_list(:search_history, 3)
    end

    let(:query) do
      <<~GQL
        query {
          total_search_histories_count
        }
      GQL
    end

    it "returns the total count of SearchHistories" do
      response_json = perform_post_query(query)
      expect(response_json).to have_key("data")
      data = response_json["data"]["total_search_histories_count"]
      expect(data).to eq(3)
    end
  end
end
