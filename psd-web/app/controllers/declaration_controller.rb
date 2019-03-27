class DeclarationController < ApplicationController
  skip_before_action :has_accepted_declaration

  def declaration
    @error_list = []
    if request.get?
      store_original_path
      return
    end
    if params[:agree_to_declaration] != "checked"
      @error_list << { text: "You must agree to the declaration to use this service" }
      return
    end
    User.current.has_accepted_declaration!
    redirect_to session[:original_path] || root_path
  end

private

  def store_original_path
    session[:original_path] = params[:format]
  end
end
