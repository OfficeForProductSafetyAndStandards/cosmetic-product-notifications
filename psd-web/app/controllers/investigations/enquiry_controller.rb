class Investigations::EnquiryController < Investigations::CreationFlowController
  set_attachment_names :attachment
  set_file_params_key :enquiry

  steps :about_enquiry, :complainant, :complainant_details, :enquiry_details

private

  def model_key
    :enquiry
  end

  def model_params
    %i[user_title description date_received]
  end

  def set_investigation
    p "Set inv"
    @investigation = Investigation::Enquiry.new(investigation_params)
    @investigation.set_dates_from_params(params[:enquiry])
  end

  def success_message
    "Enquiry was successfully created."
  end

  def set_page_title
    @page_title = "New enquiry"
    @page_subtitle = "Who did the enquiry come from?"
  end
end
