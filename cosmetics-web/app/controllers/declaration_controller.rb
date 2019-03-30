class DeclarationController < ApplicationController
  skip_before_action :authorize_user!
  skip_before_action :has_accepted_declaration
  skip_before_action :create_or_join_responsible_person

  def show
    session[:redirect_path] = params[:redirect_path]
  end

  def accept
    if params[:agree_to_declaration] != "checked"
      @errors = [{ text: "You must agree to the declaration to use this service", href: "#agree_to_declaration" }]
      render :index
    else
      User.current.has_accepted_declaration!
      redirect_to session[:redirect_path] || root_path
    end
  end
end
