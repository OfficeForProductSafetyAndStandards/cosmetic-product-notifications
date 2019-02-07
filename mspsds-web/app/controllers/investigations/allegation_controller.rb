class Investigations::AllegationController < Investigations::CreationFlowController
  set_attachment_names :attachment
  set_file_params_key :allegation

  steps :complainant, :complainant_details, :allegation_details

private

  def model_key
    :allegation
  end

  def model_params
    %i[description hazard_type product_category]
  end

  def set_investigation
    @investigation = Investigation::Allegation.new(investigation_params)
  end

  def success_message
    "Allegation was successfully created"
  end

  def set_page_title
    @page_title = "New Allegation"
    @page_subtitle = "Who's making the allegation?"
  end
end
