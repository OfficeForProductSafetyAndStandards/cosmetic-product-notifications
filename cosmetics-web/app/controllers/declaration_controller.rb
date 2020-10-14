class DeclarationController < ApplicationController
  skip_before_action :authorize_user!

  def show
    session[:redirect_path] = params[:redirect_path]
    show_declaration
  end

  def accept
    current_user.update(has_accepted_declaration: true)
    redirect_to session[:redirect_path] || root_path
  end

private

  def show_declaration
    if current_user&.poison_centre_user?
      render "poison_centre_declaration"
    elsif current_user&.msa_user?
      render "msa_user_declaration"
    else
      render "business_declaration"
    end
  end
end
