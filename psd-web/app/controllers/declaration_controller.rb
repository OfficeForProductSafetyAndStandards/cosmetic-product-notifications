class DeclarationController < ApplicationController
  skip_before_action :has_accepted_declaration

  def index
    session[:redirect_path] = params[:redirect_path]
  end

  def accept
    @error_list = []
    if params[:agree_to_declaration] != "checked"
      @error_list << { text: "You must agree to the declaration to use this service" }
      return render :index
    end
    User.current.has_accepted_declaration!
    redirect_to session[:redirect_path] || root_path
  end
end
