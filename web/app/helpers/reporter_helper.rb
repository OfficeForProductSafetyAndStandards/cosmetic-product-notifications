module ReporterHelper
  def load_reporter_and_investigation
    load_investigation
    load_reporter
  end

  def load_reporter
    data_from_database = @investigation&.reporter&.attributes || {}
    data_from_previous_steps = data_from_database.merge(session[:reporter] || {})
    data_after_last_step = data_from_previous_steps.merge(params[:reporter]&.permit! || {})
    params[:reporter] = data_after_last_step
    session[:reporter] = reporter_params
    @reporter = Reporter.new(session[:reporter])
  end

  def reporter_params
    return {} if !params[:reporter] || params[:reporter] == {}
    if params[:reporter][:reporter_type] == 'Other'
      params[:reporter][:reporter_type] = params[:reporter][:other_reporter]
    end
    params.require(:reporter).permit(
      :name, :phone_number, :email_address, :reporter_type, :other_details
    )
  end
end
