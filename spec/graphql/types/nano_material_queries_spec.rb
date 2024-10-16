require "rails_helper"

RSpec.describe Types::NanoMaterialQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  def perform_post_query(variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "nano_material query" do
    let(:nano_material) { create(:nano_material) }
    let(:query) do
      <<~GQL
        query($id: ID!) {
          nano_material(id: $id) {
            id
            created_at
            updated_at
            notification_id
            inci_name
            cas_number
          }
        }
      GQL
    end

    it "returns a NanoMaterial by ID" do
      response_json = perform_post_query({ id: nano_material.id })
      data = response_json["data"]["nano_material"]
      expect(data["id"]).to eq(nano_material.id.to_s)
    end

    it "returns inci_name for the NanoMaterial by ID" do
      response_json = perform_post_query({ id: nano_material.id })
      data = response_json["data"]["nano_material"]
      expect(data["inci_name"]).to eq(nano_material.inci_name)
    end

    it "returns cas_number for the NanoMaterial by ID" do
      response_json = perform_post_query({ id: nano_material.id })
      data = response_json["data"]["nano_material"]
      expect(data["cas_number"]).to eq(nano_material.cas_number)
    end
  end

  describe "nano_materials query" do
    let!(:recent_nano_material) { create(:nano_material, created_at: "2023-08-10", updated_at: "2023-08-15") }
    let(:query) do
      <<~GQL
        query($created_after: String, $first: Int) {
          nano_materials(created_after: $created_after, first: $first) {
            edges {
              node {
                id
                inci_name
                cas_number
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

    context "when filtering NanoMaterials" do
      let(:variables) { { created_after: "2023-08-05T00:00:00Z", first: 10 } }

      it "returns a filtered list based on created_after" do
        response_json = perform_post_query(variables)
        data = response_json["data"]["nano_materials"]["edges"]
        expect(data.size).to eq(1)
      end

      it "returns inci_name for the filtered NanoMaterial" do
        response_json = perform_post_query(variables)
        data = response_json["data"]["nano_materials"]["edges"]
        expect(data.first["node"]["inci_name"]).to eq(recent_nano_material.inci_name)
      end

      it "returns cas_number for the filtered NanoMaterial" do
        response_json = perform_post_query(variables)
        data = response_json["data"]["nano_materials"]["edges"]
        expect(data.first["node"]["cas_number"]).to eq(recent_nano_material.cas_number)
      end
    end

    context "when checking pagination info" do
      let(:variables) { { created_after: "2023-08-05T00:00:00Z", first: 10 } }

      it "checks hasNextPage in pagination info" do
        response_json = perform_post_query(variables)
        page_info = response_json["data"]["nano_materials"]["pageInfo"]
        expect(page_info["hasNextPage"]).to be(false)
      end

      it "checks hasPreviousPage in pagination info" do
        response_json = perform_post_query(variables)
        page_info = response_json["data"]["nano_materials"]["pageInfo"]
        expect(page_info["hasPreviousPage"]).to be(false)
      end

      it "checks startCursor in pagination info" do
        response_json = perform_post_query(variables)
        page_info = response_json["data"]["nano_materials"]["pageInfo"]
        expect(page_info["startCursor"]).not_to be_nil
      end

      it "checks endCursor in pagination info" do
        response_json = perform_post_query(variables)
        page_info = response_json["data"]["nano_materials"]["pageInfo"]
        expect(page_info["endCursor"]).not_to be_nil
      end
    end
  end

  describe "total_nano_materials_count query" do
    let!(:nano_materials) { create_list(:nano_material, 3) }
    let(:query) do
      <<~GQL
        query {
          total_nano_materials_count
        }
      GQL
    end

    it "returns the total count of NanoMaterials" do
      response_json = perform_post_query({})
      data = response_json["data"]["total_nano_materials_count"]
      expect(data).to eq(nano_materials.size)
    end
  end
end
