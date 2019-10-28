class DeclarationController < ApplicationController
  skip_before_action :authorize_user!
  skip_before_action :has_accepted_declaration
  skip_before_action :create_or_join_responsible_person

  def show
    session[:redirect_path] = params[:redirect_path]
    show_declaration
  end

  def accept
    if params[:accept_declaration] != "checked"

      error_message = if current_user.poison_centre_user? || current_user.msa_user?
                        "You must agree to the declaration to use this service"
                      else
                        "You must confirm the declaration to use this service"
                      end

      @errors = [{ text: error_message, href: "#accept_declaration" }]
      show_declaration
    else
      User.current.has_accepted_declaration!
      redirect_to session[:redirect_path] || root_path
    end
  end

private

  def show_declaration
    if User.current&.poison_centre_user?
      render "poison_centre_declaration"
    elsif current_user&.msa_user?
      render "msa_user_declaration"
    else
      render "business_declaration"
    end
  end
end
