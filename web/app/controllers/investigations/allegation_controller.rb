class Investigations::AllegationController < Investigations::CreationFlowController
  set_attachment_names :attachment
  set_file_params_key :allegation

  steps :reporter, :reporter_details, :allegation_details

private

  def model_key
    :allegation
  end

  def model_params
    %i[description hazard_type product_type]
  end

  def success_message
    "Allegation was successfully created."
  end

  def set_page_title
    @page_title = "New Allegation"
    @page_subtitle = "Who's making the allegation?"
  end

  def investigation_params
    super.merge(is_case: true)
  end
end
