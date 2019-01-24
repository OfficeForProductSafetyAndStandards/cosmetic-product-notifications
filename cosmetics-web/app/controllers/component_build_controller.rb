class ComponentBuildController < ApplicationController
    include Wicked::Wizard

    steps :number_of_shades, :add_shades

    before_action :set_component

    def show
        render_wizard
    end

    def update
        if step == :number_of_shades
            if params[:number_of_shades] == 'single'
                redirect_to edit_notification_path(@component.notification)
            else
                render_wizard @component
            end
        else
            @component.update(component_params)
            render_wizard @component
        end
    end

    def new
        redirect_to wizard_path(steps.first, component_id: @component.id)
    end

    def finish_wizard_path
        edit_notification_path(@component.notification)
    end

private

    def component_params
        params.require(:component).permit(shades: [])
    end

    def set_component
        @component = Component.find(params[:component_id])
    end
end
