class Investigations::QuestionController < Investigations::FlowController
  steps :questioner_type, :questioner_details, :question_details, :confirmation

  def update
    load_reporter_and_investigation
    if @reporter.invalid?(step) || @investigation.invalid?(step)
      render step
    else
      create if next_step? :confirmation
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
      :title, :description, :question_type
    )
  end

  def default_investigation
    Investigation.new(investigation_params.merge(is_case: false))
  end
end
