require "rails_helper"

RSpec.describe Types::NotificationQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  # Helper method to perform the GraphQL post request
  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "notification query" do
    let(:notification) { create(:notification) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          notification(id: $id) {
            id
            product_name
            state
            created_at
            updated_at
            import_country
            responsible_person_id
            reference_number
            cpnp_reference
            shades
            industry_reference
            cpnp_notification_date
            was_notified_before_eu_exit
            under_three_years
            still_on_the_market
            components_are_mixed
            ph_min_value
            ph_max_value
            notification_complete_at
            csv_cache
          }
        }
      GQL
    end

    def query_notification_and_extract_data(id)
      response_json = perform_post_query(query, { id: })
      response_json["data"]["notification"]
    end

    it "returns a Notification by ID" do
      data = query_notification_and_extract_data(notification.id)
      expect(data).to have_key("id")
      expect(data["id"]).to eq(notification.id.to_s)
    end

    it "returns the associated product_name" do
      data = query_notification_and_extract_data(notification.id)
      expect(data["product_name"]).to eq(notification.product_name)
    end

    it "returns the associated state" do
      data = query_notification_and_extract_data(notification.id)
      expect(data["state"]).to eq(notification.state)
    end

    it "returns created_at timestamp" do
      data = query_notification_and_extract_data(notification.id)
      expect(data["created_at"]).to eq(notification.created_at.utc.iso8601)
    end

    it "returns updated_at timestamp" do
      data = query_notification_and_extract_data(notification.id)
      expect(data["updated_at"]).to eq(notification.updated_at.utc.iso8601)
    end

    it "returns the associated import_country" do
      data = query_notification_and_extract_data(notification.id)
      expect(data["import_country"]).to eq(notification.import_country)
    end

    it "returns an error when Notification not found" do
      response_json = perform_post_query(query, { id: -1 })
      expect(response_json).to have_key("errors")
      errors = response_json["errors"]
      expect(errors.first["message"]).to eq("Couldn't find notification with 'id' -1")
    end
  end

  describe "notifications query" do
    let!(:recent_notification) { create(:notification, created_at: "2024-08-10", updated_at: "2024-08-15") }
    let(:older_notification) { create(:notification, created_at: "2024-08-01", updated_at: "2024-08-05") }

    let(:query) do
      <<~GQL
        query($created_after: String, $updated_after: String, $first: Int) {
          notifications(created_after: $created_after, updated_after: $updated_after, first: $first) {
            edges {
              node {
                id
                product_name
                state
                created_at
                updated_at
                import_country
                responsible_person_id
                reference_number
                cpnp_reference
                shades
                industry_reference
                cpnp_notification_date
                was_notified_before_eu_exit
                under_three_years
                still_on_the_market
                components_are_mixed
                ph_min_value
                ph_max_value
                notification_complete_at
                csv_cache
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

    def query_notifications(created_after: nil, updated_after: nil, first: nil)
      perform_post_query(query, { created_after:, updated_after:, first: })
    end

    it "returns the total number of Notifications" do
      response_json = query_notifications(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "notifications", "edges").size).to eq(1)
    end

    it "returns the associated product_name for the first notification" do
      response_json = query_notifications(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "notifications", "edges").first["node"]["product_name"]).to eq(recent_notification.product_name)
    end

    it "checks pagination hasNextPage is false" do
      response_json = query_notifications(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "notifications", "pageInfo")
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "checks pagination hasPreviousPage is false or nil" do
      response_json = query_notifications(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "notifications", "pageInfo")
      expect(page_info["hasPreviousPage"]).to be(false).or(be_nil)
    end

    it "checks pagination startCursor is not nil" do
      response_json = query_notifications(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "notifications", "pageInfo")
      expect(page_info["startCursor"]).not_to be_nil
    end

    it "checks pagination endCursor is not nil" do
      response_json = query_notifications(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "notifications", "pageInfo")
      expect(page_info["endCursor"]).not_to be_nil
    end
  end

  describe "total_notification_count query" do
    before do
      create_list(:notification, 3)
    end

    let(:query) do
      <<~GQL
        query {
          total_notification_count
        }
      GQL
    end

    it "returns the total count of Notifications" do
      response_json = perform_post_query(query)
      expect(response_json).to have_key("data")
      data = response_json["data"]["total_notification_count"]
      expect(data).to eq(3)
    end
  end
end
