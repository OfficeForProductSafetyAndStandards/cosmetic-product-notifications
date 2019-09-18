class GuidanceController < ApplicationController

  skip_before_action :authenticate_user!, only: [:how_to_create_your_list_of_ingredients]
  skip_before_action :authorize_user!, only: [:how_to_create_your_list_of_ingredients]


  def how_to_notify_nanomaterials; end

  def how_to_prepare_images_for_notification; end

  def how_to_create_your_list_of_ingredients
  end
end
