require "rails_helper"

RSpec.describe Types::ContactPersonQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "contact_person query" do
    let(:contact_person) { create(:contact_person) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          contact_person(id: $id) {
            id
            name
            email_address
            phone_number
            responsible_person_id
            created_at
            updated_at
          }
        }
      GQL
    end

    it "returns a ContactPerson by ID" do
      response_json = perform_post_query(query, { id: contact_person.id })
      data = response_json.dig("data", "contact_person")

      expect(response_json).to have_key("data")
      expect(data["id"]).to eq(contact_person.id.to_s)
    end

    it "returns the ContactPerson's name" do
      response_json = perform_post_query(query, { id: contact_person.id })
      data = response_json.dig("data", "contact_person")

      expect(data["name"]).to eq(contact_person.name)
    end

    it "returns the ContactPerson's email address" do
      response_json = perform_post_query(query, { id: contact_person.id })
      data = response_json.dig("data", "contact_person")

      expect(data["email_address"]).to eq(contact_person.email_address)
    end

    it "returns the ContactPerson's responsible person ID" do
      response_json = perform_post_query(query, { id: contact_person.id })
      data = response_json.dig("data", "contact_person")

      expect(data["responsible_person_id"]).to eq(contact_person.responsible_person_id.to_s)
    end

    it "returns an error when ContactPerson not found" do
      response_json = perform_post_query(query, { id: -1 })
      errors = response_json["errors"]

      expect(response_json).to have_key("errors")
      expect(errors.first["message"]).to eq("Couldn't find contact_person with 'id' -1")
    end
  end

  describe "contact_persons query" do
    let!(:recent_contact_person) { create(:contact_person, created_at: "2023-08-10", updated_at: "2023-08-15") }
    let(:older_contact_person) { create(:contact_person, created_at: "2023-08-01", updated_at: "2023-08-05") }

    let(:query) do
      <<~GQL
        query($created_after: String, $first: Int) {
          contact_persons(created_after: $created_after, first: $first) {
            edges {
              node {
                id
                name
                email_address
                responsible_person_id
                created_at
                updated_at
              }
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

    it "returns a list of ContactPersons" do
      response_json = perform_post_query(query, { created_after: "2023-08-05T00:00:00Z", first: 10 })
      data = response_json["data"]["contact_persons"]["edges"]

      expect(response_json).to have_key("data")
      expect(data.size).to eq(1)
      expect_contact_person_data(data.first["node"], recent_contact_person)
    end

    it "returns the correct pagination info" do
      response_json = perform_post_query(query, { created_after: "2023-08-05T00:00:00Z", first: 10 })
      page_info = response_json["data"]["contact_persons"]["pageInfo"]

      expect(response_json).to have_key("data")
      expect_pagination_info(page_info)
    end

    def expect_contact_person_data(data, contact_person)
      expect(data["id"]).to eq(contact_person.id.to_s)
      expect(data["name"]).to eq(contact_person.name)
      expect(data["email_address"]).to eq(contact_person.email_address)
      expect(data["responsible_person_id"]).to eq(contact_person.responsible_person_id.to_s)
    end

    def expect_pagination_info(page_info)
      expect(page_info["hasNextPage"]).to be(false)
      expect(page_info["hasPreviousPage"]).to be(false)
      expect(page_info["startCursor"]).not_to be_nil
      expect(page_info["endCursor"]).not_to be_nil
    end
  end

  describe "total_contact_persons_count query" do
    before do
      create_list(:contact_person, 3)
    end

    let(:query) do
      <<~GQL
        query {
          total_contact_persons_count
        }
      GQL
    end

    it "returns the total count of ContactPersons" do
      response_json = perform_post_query(query)
      data = response_json["data"]["total_contact_persons_count"]

      expect(response_json).to have_key("data")
      expect(data).to eq(3)
    end
  end
end
