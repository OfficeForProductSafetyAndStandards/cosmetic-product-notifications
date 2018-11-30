class CreateController < ApplicationController
  before_action :set_available_options

  # GET /create/new
  def new; end

  # POST /create
  def create
    type = request_params[:type]
    case type
    when "question"
      redirect_to new_question_path
    else
      @nothing_selected = true
      render :new
    end
  end

private

  def set_available_options
    @available_options = {
      allegation: "Product safety allegation",
      question: "Question",
      product_recall: "Product recall notification",
      rapex_notification: "Notification from RAPEX"
    }
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_params
    params.permit(:type)
  end
end
