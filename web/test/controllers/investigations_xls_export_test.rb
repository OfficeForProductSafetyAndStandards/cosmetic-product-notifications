require "test_helper"

class InvestigationsXlsExportTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @investigation_one = investigations(:one)
    @investigation_two = investigations(:two)
    Investigation.import refresh: true

    get investigations_path format: :xlsx
    @tempfile = File.new(Rails.root + 'test/fixtures/files/cases.xlsx')
    File.open(@tempfile.path, 'w') {|f| f.write response.body}
    @file = Roo::Excelx.new(@tempfile.path)
  end

  teardown do
    logout
  end

  test "should have specified sheets" do
    assert_includes(@file.sheets, 'Cases')
    assert_includes(@file.sheets, 'Products')
    assert_includes(@file.sheets, 'Businesses')
    assert_includes(@file.sheets, 'Businesses locations')
    assert_includes(@file.sheets, 'Actions')
    assert_includes(@file.sheets, 'Correspondences')
    assert_includes(@file.sheets, 'Corrective actions')
    assert_includes(@file.sheets, 'Tests')
  end

  test "should create excel file for list of investigations" do
    cases_rows = rows_in_sheet(@file.sheet('Cases'))
    row_for_case_one = row_for_case(@investigation_one)
    row_for_case_two = row_for_case(@investigation_two)
    assert_includes cases_rows, row_for_case_one
    assert_includes cases_rows, row_for_case_two
  end

  def row_for_case(investigation)
    [investigation.pretty_id, investigation.status, investigation.title,
     investigation.description, investigation.product_type, investigation.hazard_type,
     investigation.assignee&.email_address || 'Unassigned', investigation.source&.show,
     investigation.reporter&.name, investigation.reporter&.email_address,
     investigation.reporter&.phone_number, investigation.reporter&.reporter_type,
     investigation.products.count.to_s, investigation.businesses.count.to_s,
     investigation.activities.count.to_s, investigation.correspondences.count.to_s,
     investigation.corrective_actions.count.to_s, investigation.tests.count.to_s]
  end

  def rows_in_sheet(sheet)
    [*1..sheet.last_row].map {|n| sheet.row(n)}
  end
end
