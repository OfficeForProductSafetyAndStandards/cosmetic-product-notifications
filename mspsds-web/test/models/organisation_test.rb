require "test_helper"

class OrganisationTest < ActiveSupport::TestCase
  setup do
    @organisations = [
      { id: "def4eef8-1a33-4322-8b8c-fc7fa95a2e3b", name: "Organisation 1", path: "/Organisations/Organisation 1", subGroups: [] },
      { id: "1a612aea-1d3d-47ee-8c3a-76b4448bb97b", name: "Organisation 2", path: "/Organisations/Organisation 2", subGroups: [] },
    ]

    groups = [
      { id: "13763657-d228-4209-a3de-523dcab13810", name: "Group 1", path: "/Group 1", subGroups: [] },
      { id: "10036801-2182-4c5b-92d9-b34b1e0a421b", name: "Group 2", path: "/Group 2", subGroups: [] },
      { id: "512c85e6-5a7f-4289-95e2-a78c0e40f05c", name: "Organisations", path: "/Organisations", subGroups: @organisations }
    ].to_json

    allow(Keycloak::Internal).to receive(:get_groups).and_return(groups)
  end

  teardown do
    allow(Keycloak::Internal).to receive(:get_groups).and_call_original
  end

  test "all Keycloak organisations are added" do
    Rails.cache.delete(:keycloak_groups)
    all_organisations = Organisation.all

    assert_same_elements @organisations.map { |org| org[:id] }, all_organisations.pluck(:id)
  end

  test "all organisation properties are populated" do
    Rails.cache.delete(:keycloak_groups)
    all_organisations = Organisation.all

    assert_same_elements @organisations.map { |org| org[:name] }, all_organisations.pluck(:name)
    assert_same_elements @organisations.map { |org| org[:path] }, all_organisations.pluck(:path)
  end

  test "all non-organisation groups are excluded" do
    Rails.cache.delete(:keycloak_groups)
    all_organisations = Organisation.all

    assert_not_includes all_organisations.pluck(:name), "Group 1"
    assert_not_includes all_organisations.pluck(:name), "Group 2"
  end
end
