class Shared::Web::ComponentsGalleryController < Shared::Web::ApplicationController
  def show
    component = params[:component]
    layout = case component
             when "header"
               "shared/web/_head"
             else
               "shared/web/component_gallery"
             end
    render "components_gallery/#{component}", layout: layout
  end
end
