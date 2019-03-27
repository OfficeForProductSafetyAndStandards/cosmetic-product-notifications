class Investigations::ProjectController < ApplicationController
  before_action :set_investigation, only: %i[new create]

  def new; end

  def create
    if @investigation.valid?
      @investigation.save
      redirect_to investigation_path(@investigation), flash: { success: "Project was successfully created" }
    else
      render :new
    end
  end

private

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    return {} if params[:investigation].blank?

    params.require(:investigation).permit(:user_title, :description)
  end

  def set_investigation
    @investigation = Investigation::Project.new(project_params)
  end
end
