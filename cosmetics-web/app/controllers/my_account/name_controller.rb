module MyAccount
  class NameController < ApplicationController
    def edit
      @user = current_user
    end

    def update
      @user = current_user

      @user.name = dig_params(:name)

      if @user.save
        redirect_to my_account_path, confirmation: "Name changed successfully"
      else
        render :edit
      end
    end
  end
end
