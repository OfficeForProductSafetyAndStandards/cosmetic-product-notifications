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
    send_welcome_email unless User.current.has_been_sent_welcome_email
    redirect_to session[:redirect_path] || root_path
  end

  def set_errors
    @error_list = []
  end

  def send_welcome_email
    NotifyMailer.welcome(User.current.name, User.current.email).deliver_later
    User.current.has_been_sent_welcome_email!
  end
end
