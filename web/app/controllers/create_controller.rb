class CreateController < ApplicationController

  # GET /create/new
  def new; end

  # POST /create
  def create
    type = request_params[:type]
    case type
    when "question"
      redirect_to new_question_path
    else
      render :new
    end
  end

private

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_params
    params.require(:create).permit(:type)
  end
end
