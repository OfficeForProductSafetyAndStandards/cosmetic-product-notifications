class Investigations::AssignController < ApplicationController
  include Wicked::Wizard
  before_action :set_investigation
  before_action :find_potential_assignee, only: %i[show create]
  before_action :store_assignee, only: %i[update]

  steps :choose, :confirm_assignment_change

  def show
    render_wizard
  end

  def new
    clear_session
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def update
    redirect_to next_wizard_path
  end

  def create
    @investigation.assignee = @potential_assignees.first
    @investigation.assignee_comment = params[:investigation][:assignee_comment]
    @investigation.save
    respond_to_update
  end

private

  def clear_session
    session[:assignable_id] = nil
  end

  def set_investigation
    @investigation = Investigation.find_by!(pretty_id: params[:investigation_pretty_id])
    authorize @investigation, :show?
  end

  def filter_assignee_params
    params[:investigation][:assignable_id] = case params[:investigation][:assignable_id]
                                             when "someone_in_your_team"
                                               params[:investigation][:select_team_member]
                                             when "previously_assigned"
                                               params[:investigation][:select_previously_assigned]
                                             when "other_team"
                                               params[:investigation][:select_other_team]
                                             when "someone_else"
                                               params[:investigation][:select_someone_else]
                                             else
                                               params[:investigation][:assignable_id]
                                             end
    params.require(:investigation).permit(:assignable_id)
  end

  def store_assignee
    filter_assignee_params
    session[:assignable_id] = params[:investigation][:assignable_id]
    if session[:assignable_id].blank?
      @investigation.errors.add(:assignable_id, :invalid, message: "Select assignee")
      respond_to_invalid_data
      return
    end
  end

  def find_potential_assignee
    @potential_assignees = User.where(id: session[:assignable_id]) + Team.where(id: session[:assignable_id])
  end

  def respond_to_update
    respond_to do |format|
      if @investigation.save
        format.html { redirect_to @investigation, notice: "#{@investigation.case_type.titleize} was successfully updated." }
        format.json { render :show, status: :ok, location: @investigation }
      else
        @investigation.restore_attributes
        format.html { render step }
        format.json { render json: @investigation.errors, status: :unprocessable_entity }
      end
    end
  end

  def respond_to_invalid_data
    respond_to do |format|
      format.html { render step }
      format.json { render json: @corrective_action.errors, status: :unprocessable_entity }
    end
  end
end
