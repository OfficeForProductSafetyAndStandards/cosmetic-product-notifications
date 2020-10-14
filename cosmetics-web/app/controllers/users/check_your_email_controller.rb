module Users
  class CheckYourEmailController < Devise::PasswordsController
    # This is just a static page
    def show; end
  end
end
