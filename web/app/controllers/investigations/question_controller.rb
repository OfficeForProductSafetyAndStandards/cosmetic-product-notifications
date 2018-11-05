class Investigations::QuestionController < Investigations::FlowController
  steps :questioner_type, :questioner_details, :question_details

  def update
    load_reporter_and_investigation
    if @reporter.invalid?(step) || @investigation.invalid?(step)
      render step
    elsif step == steps.last
      create
      redirect_to confirmation_investigation_path(@investigation)
    else
      redirect_to next_wizard_path
    end
  end

private

  def investigation_params
    return {} if !params[:investigation]

    if params[:investigation][:question_type] == 'Other'
      params[:investigation][:question_type] = params[:investigation][:other_question_type]
    end
    params.require(:investigation).permit(
      :question_title, :description, :question_type
    )
  end

  def default_investigation
    Investigation.new(investigation_params.merge(is_case: false))
  end
end
