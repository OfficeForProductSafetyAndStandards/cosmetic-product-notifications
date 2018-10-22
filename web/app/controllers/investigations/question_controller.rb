class Investigations::QuestionController < ApplicationController
  include FlowHelper
  include Wicked::Wizard
  steps :questioner_type, :questioner_details, :question_details, :confirmation

  def update
    load_reporter_and_investigation
    create if next_step? :confirmation
    clear_session if step == :confirmation
    redirect_to next_wizard_path
  end

private

  def investigation_params
    return {} if !params[:investigation]
    if params[:investigation][:question_type] == 'other_question'
      params[:investigation][:question_type] = 'other_question: ' + params[:investigation][:other_question_type]
    end
    params.require(:investigation).permit(
      :title, :description, :question_type
    )
  end

  def default_investigation
    Investigation.new(investigation_params.merge({is_case: false}))
  end
end
