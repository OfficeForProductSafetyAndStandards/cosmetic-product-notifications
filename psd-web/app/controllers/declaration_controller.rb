class DeclarationController < ApplicationController
  skip_before_action :has_accepted_declaration
  before_action :set_errors

  def index
    session[:redirect_path] = params[:redirect_path]
  end

  def accept
    if params[:agree] != "checked"
      @error_list << :declaration_not_agreed_to
      return render :index
    end
    User.current.has_accepted_declaration!
    redirect_to session[:redirect_path] || root_path
  end

  def set_errors
    @error_list = []
  end
end
