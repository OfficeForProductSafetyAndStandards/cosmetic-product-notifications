class Investigations::AssignController < ApplicationController
  include Wicked::Wizard
  before_action :set_investigation
  before_action :store_assignee, only: %i[update]

  steps :choose, :confirm_assignment_change

  def show
    if step == :confirm_assignment_change
      set_potential_assignee
    end
    render_wizard
  end

  def new
    clear_session
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def update
    if step == :choose

    end
    redirect_to next_wizard_path
  end

  def create
    @investigation.assignee = @potential_assignees.first
    @investigation.save
    redirect_to investigation_url(@investigation)
  end

private

  def clear_session
    session[:assignable_id] = nil
  end

  def set_investigation
    @investigation = Investigation.find_by!(pretty_id: params[:investigation_pretty_id])
    authorize @investigation, :show?
  end

  def store_assignee
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
      session[:assignable_id] = params[:investigation][:assignable_id]
      if session[:assignable_id].blank?
        @investigation.errors.add(:assignable_id, :invalid, message: "Select assignee")
        respond_to_invalid_data
        return
      else
    end
    
  end

  def set_potential_assignee
    @potential_assignees = User.where(id: session[:assignable_id]) + Team.where(id: session[:assignable_id])

  end

  def respond_to_update(origin)
    respond_to do |format|
      if @investigation.save
        format.html { redirect_to @investigation, notice: "#{@investigation.case_type.titleize} was successfully updated." }
        format.json { render :show, status: :ok, location: @investigation }
      else
        @investigation.restore_attributes
        format.html { render origin }
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

  def assign_params
    params.require(:assign).permit(:business_id, :name, :email, :phone_number, :job_title)
  end
end
