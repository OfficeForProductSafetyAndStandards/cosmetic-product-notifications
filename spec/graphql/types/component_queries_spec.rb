require "rails_helper"

RSpec.describe Types::ComponentQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "component query" do
    let(:component) { create(:component) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          component(id: $id) {
            id
            name
            state
            notification_id
          }
        }
      GQL
    end

    it "returns a Component by ID" do
      response_json = perform_post_query(query, { id: component.id })

      expect(response_json).to have_key("data")
      data = response_json["data"]["component"]

      expect(data["id"]).to eq(component.id.to_s)
    end

    it "returns the name of the Component" do
      response_json = perform_post_query(query, { id: component.id })
      data = response_json["data"]["component"]

      expect(data["name"]).to eq(component.name)
    end

    it "returns the notification_id of the Component" do
      response_json = perform_post_query(query, { id: component.id })
      data = response_json["data"]["component"]

      expect(data["notification_id"]).to eq(component.notification_id.to_s)
    end

    it "returns the state of the Component" do
      response_json = perform_post_query(query, { id: component.id })
      data = response_json["data"]["component"]

      expect(data["state"]).to eq(component.state)
    end

    it "returns an error when Component not found" do
      response_json = perform_post_query(query, { id: -1 })

      expect(response_json).to have_key("errors")
      errors = response_json["errors"]

      expect(errors.first["message"]).to eq("Couldn't find component with 'id' -1")
    end
  end

  describe "components query" do
    let!(:recent_component) { create(:component, created_at: "2023-08-10", updated_at: "2023-08-15") }
    let(:query) do
      <<~GQL
        query($created_after: String, $first: Int) {
          components(created_after: $created_after, first: $first) {
            edges {
              node {
                id
                name
                state
                notification_id
              }
            }
            pageInfo {
              hasNextPage
              hasPreviousPage
            }
          }
        }
      GQL
    end
    let(:older_component) { create(:component, created_at: "2023-08-01", updated_at: "2023-08-05") }

    before do
      create(:component, created_at: "2023-07-01")
      create(:component, created_at: "2023-07-15")
    end

    it "returns data key in response" do
      response_json = perform_post_query(query, {
        created_after: "2023-08-05T00:00:00Z",
        first: 10,
      })

      expect(response_json).to have_key("data")
    end

    it "returns components key in response" do
      response_json = perform_post_query(query, {
        created_after: "2023-08-05T00:00:00Z",
        first: 10,
      })

      expect(response_json["data"]).to have_key("components")
    end

    it "returns the correct number of recent components after created_after" do
      response_json = perform_post_query(query, {
        created_after: "2023-08-05T00:00:00Z",
        first: 10,
      })

      expect(response_json["data"]["components"]["edges"].size).to eq(1)
    end

    it "confirms there is one recent component after created_after" do
      response_json = perform_post_query(query, {
        created_after: "2023-08-05T00:00:00Z",
        first: 10,
      })

      data = response_json["data"]["components"]["edges"]
      expect(data.size).to eq(1)
    end

    it "returns the ID of the recent component" do
      response_json = perform_post_query(query, {
        created_after: "2023-08-05T00:00:00Z",
        first: 10,
      })

      data = response_json["data"]["components"]["edges"].first["node"]
      expect(data["id"]).to eq(recent_component.id.to_s)
    end

    it "returns the name of the recent component" do
      response_json = perform_post_query(query, {
        created_after: "2023-08-05T00:00:00Z",
        first: 10,
      })

      data = response_json["data"]["components"]["edges"].first["node"]
      expect(data["name"]).to eq(recent_component.name)
    end

    it "returns the state of the recent component" do
      response_json = perform_post_query(query, {
        created_after: "2023-08-05T00:00:00Z",
        first: 10,
      })

      data = response_json["data"]["components"]["edges"].first["node"]
      expect(data["state"]).to eq(recent_component.state)
    end

    it "returns the notification_id of the recent component" do
      response_json = perform_post_query(query, {
        created_after: "2023-08-05T00:00:00Z",
        first: 10,
      })

      data = response_json["data"]["components"]["edges"].first["node"]
      expect(data["notification_id"]).to eq(recent_component.notification_id.to_s)
    end

    it "checks pagination info for hasNextPage" do
      response_json = perform_post_query(query, {
        created_after: "2023-08-05T00:00:00Z",
        first: 10,
      })

      page_info = response_json["data"]["components"]["pageInfo"]
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "checks pagination info for hasPreviousPage" do
      response_json = perform_post_query(query, {
        created_after: "2023-08-05T00:00:00Z",
        first: 10,
      })

      page_info = response_json["data"]["components"]["pageInfo"]
      expect(page_info["hasPreviousPage"]).to be(false).or(be_nil)
    end
  end

  describe "total_components_count query" do
    before do
      create_list(:component, 3)
    end

    let(:query) do
      <<~GQL
        query {
          total_components_count
        }
      GQL
    end

    it "returns the total count of Components" do
      response_json = perform_post_query(query)

      expect(response_json).to have_key("data")
      data = response_json["data"]["total_components_count"]

      expect(data).to eq(3)
    end
  end
end
