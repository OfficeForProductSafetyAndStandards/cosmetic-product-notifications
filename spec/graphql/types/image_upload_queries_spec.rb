require "rails_helper"

RSpec.describe Types::ImageUploadQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  # Helper method to perform the GraphQL post request
  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "image_upload query" do
    let(:image_upload) { create(:image_upload) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          image_upload(id: $id) {
            id
            filename
            created_at
            updated_at
            notification_id
            notification {
              id
              product_name
            }
          }
        }
      GQL
    end

    def query_image_upload_and_extract_data(id)
      response_json = perform_post_query(query, { id: })
      response_json["data"]["image_upload"]
    end

    it "returns an ImageUpload by ID" do
      data = query_image_upload_and_extract_data(image_upload.id)
      expect(data).to have_key("id")
      expect(data["id"]).to eq(image_upload.id.to_s)
    end

    it "returns the associated filename" do
      data = query_image_upload_and_extract_data(image_upload.id)
      expect(data["filename"]).to eq(image_upload.filename)
    end

    it "returns created_at timestamp" do
      data = query_image_upload_and_extract_data(image_upload.id)
      expect(data["created_at"]).to eq(image_upload.created_at.utc.iso8601)
    end

    it "returns updated_at timestamp" do
      data = query_image_upload_and_extract_data(image_upload.id)
      expect(data["updated_at"]).to eq(image_upload.updated_at.utc.iso8601)
    end

    it "returns the associated notification_id" do
      data = query_image_upload_and_extract_data(image_upload.id)
      expect(data["notification_id"]).to eq(image_upload.notification_id.to_s)
    end

    it "returns the associated notification details" do
      data = query_image_upload_and_extract_data(image_upload.id)
      expect(data["notification"]["id"]).to eq(image_upload.notification.id.to_s)
      expect(data["notification"]["product_name"]).to eq(image_upload.notification.product_name)
    end

    it "returns an error when ImageUpload not found" do
      response_json = perform_post_query(query, { id: -1 })
      expect(response_json).to have_key("errors")
      errors = response_json["errors"]
      expect(errors.first["message"]).to eq("Couldn't find image_upload with 'id' -1")
    end
  end

  describe "image_uploads query" do
    let!(:recent_image_upload) { create(:image_upload, created_at: "2024-08-10", updated_at: "2024-08-15") }
    let(:older_image_upload) { create(:image_upload, created_at: "2024-08-01", updated_at: "2024-08-05") }

    let(:query) do
      <<~GQL
        query($created_after: String, $updated_after: String, $first: Int) {
          image_uploads(created_after: $created_after, updated_after: $updated_after, first: $first) {
            edges {
              node {
                id
                filename
                created_at
                updated_at
                notification_id
                notification {
                  id
                  product_name
                }
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

    def query_image_uploads(created_after: nil, updated_after: nil, first: nil)
      perform_post_query(query, { created_after:, updated_after:, first: })
    end

    it "returns the total number of ImageUploads" do
      response_json = query_image_uploads(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "image_uploads", "edges").size).to eq(1)
    end

    it "returns the associated filename for the first upload" do
      response_json = query_image_uploads(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "image_uploads", "edges").first["node"]["filename"]).to eq(recent_image_upload.filename)
    end

    it "checks pagination hasNextPage is false" do
      response_json = query_image_uploads(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "image_uploads", "pageInfo")
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "checks pagination hasPreviousPage is false or nil" do
      response_json = query_image_uploads(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "image_uploads", "pageInfo")
      expect(page_info["hasPreviousPage"]).to be(false).or(be_nil)
    end

    it "checks pagination startCursor is not nil" do
      response_json = query_image_uploads(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "image_uploads", "pageInfo")
      expect(page_info["startCursor"]).not_to be_nil
    end

    it "checks pagination endCursor is not nil" do
      response_json = query_image_uploads(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "image_uploads", "pageInfo")
      expect(page_info["endCursor"]).not_to be_nil
    end
  end

  describe "total_image_uploads_count query" do
    before do
      create_list(:image_upload, 3)
    end

    let(:query) do
      <<~GQL
        query {
          total_image_uploads_count
        }
      GQL
    end

    it "returns the total count of ImageUploads" do
      response_json = perform_post_query(query)
      expect(response_json).to have_key("data")
      data = response_json["data"]["total_image_uploads_count"]
      expect(data).to eq(3)
    end
  end
end
