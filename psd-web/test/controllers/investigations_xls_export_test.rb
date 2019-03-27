require "test_helper"

class InvestigationsXlsExportTest < ActionDispatch::IntegrationTest
  setup do
    mock_out_keycloak_and_notify
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "exports all investigations" do
    path = Rails.root + 'test/fixtures/files/cases1.xlsx'
    create_stub_investigations(50)
    Investigation.import refresh: true

    count = Investigation.where(is_closed: false).count
    file = get_file(path)
    assert_equal file.sheet('Cases').last_row, count + 1
    File.delete(path)
  end

  test "treats formulas as text" do
    path = Rails.root + 'test/fixtures/files/cases2.xlsx'
    Investigation::Allegation.new(description: "=A1").save
    Investigation.import refresh: true

    file = get_file(path, "A1")
    cell_a1 = file.sheet('Cases').cell(1, 1)
    cell_bad_description = file.sheet('Cases').cell(2, 4)
    assert_equal cell_bad_description, "=A1"
    assert_not_equal cell_bad_description, nil
    assert_not_equal cell_bad_description, cell_a1
    File.delete(path)
  end

  def create_stub_investigations(how_many)
    [*1..how_many].each do
      Investigation::Allegation.new.save
    end
  end

  def get_file(path, query = "")
    get investigations_path format: :xlsx, params: { q: query }
    File.open(path, 'w') { |f| f.write response.body }
    Roo::Excelx.new(path)
  end
end
