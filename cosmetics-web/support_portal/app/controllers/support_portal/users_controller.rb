module SupportPortal
  class UsersController < ApplicationController
    def index
      search_users if params[:search_term]
    end

  protected

    def search_users
      search_term = params[:search_term]

      @users =
        if search_term.blank?
          User.page(params[:page]).per(10)
        else
          User.search(search_term).page(params[:page]).per(10)
        end
    end
  end
end
