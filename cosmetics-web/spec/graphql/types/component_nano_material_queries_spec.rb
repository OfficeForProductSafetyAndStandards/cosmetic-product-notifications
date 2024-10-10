require "rails_helper"

RSpec.describe Types::ComponentNanoMaterialQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  # Helper method to perform the GraphQL post request
  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "component_nano_material query" do
    let(:component_nano_material) { create(:component_nano_material) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          component_nano_material(id: $id) {
            id
            component {
              id
              name
              state
              shades
            }
            nano_material {
              id
              inci_name
              inn_name
              iupac_name
              xan_name
              cas_number
              ec_number
              einecs_number
            }
            created_at
            updated_at
          }
        }
      GQL
    end

    def query_component_nano_material_and_extract_data(id)
      response_json = perform_post_query(query, { id: })
      response_json["data"]["component_nano_material"]
    end

    it "returns a ComponentNanoMaterial by ID" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data).to have_key("id")
      expect(data["id"]).to eq(component_nano_material.id.to_s)
    end

    it "returns the associated component ID" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["component"]["id"]).to eq(component_nano_material.component_id.to_s)
    end

    it "returns the associated component name" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["component"]["name"]).to eq(component_nano_material.component.name)
    end

    it "returns the associated component state" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["component"]["state"]).to eq(component_nano_material.component.state)
    end

    it "returns the associated component shades" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["component"]["shades"]).to eq(component_nano_material.component.shades)
    end

    it "returns the associated nano material ID" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["nano_material"]["id"]).to eq(component_nano_material.nano_material_id.to_s)
    end

    it "returns the associated nano material INCI name" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["nano_material"]["inci_name"]).to eq(component_nano_material.nano_material.inci_name)
    end

    it "returns the associated nano material INN name" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["nano_material"]["inn_name"]).to eq(component_nano_material.nano_material.inn_name)
    end

    it "returns the associated nano material IUPAC name" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["nano_material"]["iupac_name"]).to eq(component_nano_material.nano_material.iupac_name)
    end

    it "returns the associated nano material XAN name" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["nano_material"]["xan_name"]).to eq(component_nano_material.nano_material.xan_name)
    end

    it "returns the associated nano material CAS number" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["nano_material"]["cas_number"]).to eq(component_nano_material.nano_material.cas_number)
    end

    it "returns the associated nano material EC number" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["nano_material"]["ec_number"]).to eq(component_nano_material.nano_material.ec_number)
    end

    it "returns the associated nano material EINECS number" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["nano_material"]["einecs_number"]).to eq(component_nano_material.nano_material.einecs_number)
    end

    it "returns created_at timestamp" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["created_at"]).to eq(component_nano_material.created_at.utc.iso8601)
    end

    it "returns updated_at timestamp" do
      data = query_component_nano_material_and_extract_data(component_nano_material.id)
      expect(data["updated_at"]).to eq(component_nano_material.updated_at.utc.iso8601)
    end

    it "returns an error when ComponentNanoMaterial not found" do
      response_json = perform_post_query(query, { id: -1 })
      expect(response_json).to have_key("errors")
      errors = response_json["errors"]
      expect(errors.first["message"]).to eq("Couldn't find component_nano_material with 'id' -1")
    end
  end

  describe "component_nano_materials query" do
    let!(:recent_component_nano_material) { create(:component_nano_material, created_at: "2023-08-10", updated_at: "2023-08-15") }
    let(:older_component_nano_material) { create(:component_nano_material, created_at: "2023-08-01", updated_at: "2023-08-05") }

    let(:query) do
      <<~GQL
        query($created_after: String, $first: Int) {
          component_nano_materials(created_after: $created_after, first: $first) {
            edges {
              node {
                id
                component {
                  id
                  name
                }
                nano_material {
                  id
                  inci_name
                }
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

    def query_component_nano_materials(created_after: nil, first: nil)
      perform_post_query(query, { created_after:, first: })
    end

    it "returns the total number of ComponentNanoMaterials" do
      response_json = query_component_nano_materials(created_after: "2023-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "component_nano_materials", "edges").size).to eq(1)
    end

    it "returns the associated component ID for the first material" do
      response_json = query_component_nano_materials(created_after: "2023-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "component_nano_materials", "edges").first["node"]["component"]["id"]).to eq(recent_component_nano_material.component_id.to_s)
    end

    it "returns the associated component name for the first material" do
      response_json = query_component_nano_materials(created_after: "2023-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "component_nano_materials", "edges").first["node"]["component"]["name"]).to eq(recent_component_nano_material.component.name)
    end

    it "returns the associated nano material ID for the first material" do
      response_json = query_component_nano_materials(created_after: "2023-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "component_nano_materials", "edges").first["node"]["nano_material"]["id"]).to eq(recent_component_nano_material.nano_material_id.to_s)
    end

    it "returns the associated nano material INCI name for the first material" do
      response_json = query_component_nano_materials(created_after: "2023-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "component_nano_materials", "edges").first["node"]["nano_material"]["inci_name"]).to eq(recent_component_nano_material.nano_material.inci_name)
    end

    it "checks pagination hasNextPage is false" do
      response_json = query_component_nano_materials(created_after: "2023-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "component_nano_materials", "pageInfo")
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "checks pagination hasPreviousPage is false or nil" do
      response_json = query_component_nano_materials(created_after: "2023-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "component_nano_materials", "pageInfo")
      expect(page_info["hasPreviousPage"]).to be(false).or(be_nil)
    end

    it "checks pagination startCursor is not nil" do
      response_json = query_component_nano_materials(created_after: "2023-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "component_nano_materials", "pageInfo")
      expect(page_info["startCursor"]).not_to be_nil
    end

    it "checks pagination endCursor is not nil" do
      response_json = query_component_nano_materials(created_after: "2023-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "component_nano_materials", "pageInfo")
      expect(page_info["endCursor"]).not_to be_nil
    end
  end

  describe "total_component_nano_materials_count query" do
    before do
      create_list(:component_nano_material, 3)
    end

    let(:query) do
      <<~GQL
        query {
          total_component_nano_materials_count
        }
      GQL
    end

    it "returns the total count of ComponentNanoMaterials" do
      response_json = perform_post_query(query)
      expect(response_json).to have_key("data")
      data = response_json["data"]["total_component_nano_materials_count"]
      expect(data).to eq(3)
    end
  end
end
