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

  private

  def dig_params(param)
    params.dig(user_param_key, param)
  end

  def user_class
    if params.key?("search_user")
      return SearchUser
    elsif params.key?("submit_user")
      return SubmitUser
    end

    raise ArgumentError
  end

  def user_param_key
    user_class.name.underscore.to_sym
  end
end
