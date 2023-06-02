module SupportPortal
  class UsersController < ApplicationController
    def index
      search_users if params[:search_term]
    end

  protected

    def search_users
      search_term = params[:search_term]
      search_scope = search_term.blank? ? User.all : User.search(search_term)

      @pagy, @users = pagy(search_scope, items: 10)
    end
  end
end
