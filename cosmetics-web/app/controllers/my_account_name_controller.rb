class MyAccountNameController < ApplicationController
  def show
    @user = current_user
    render "my_account/name"
  end

  def update
    @user = current_user

    @user.name = dig_params(:name)

    if @user.save
      redirect_to my_account_path, notice: "Name changed successfully"
    else
      render "my_account/name"
    end
  end
end
