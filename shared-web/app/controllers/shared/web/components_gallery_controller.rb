class Shared::Web::ComponentsGalleryController < Shared::Web::ApplicationController
  def show
    render "components_gallery/#{params[:component]}", layout: "shared/web/component_gallery"
  end
end
