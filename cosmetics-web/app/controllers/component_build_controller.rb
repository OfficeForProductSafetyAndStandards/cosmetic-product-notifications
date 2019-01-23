class ComponentBuildController < ApplicationController
    include Wicked::Wizard

    steps :number_of_shades

    before_action :set_component

    def show
        render_wizard
    end

    def update
        if step == :number_of_shades
            # TODO - Do something here....
        else
            @component.update(component_params)
        end

        render_wizard @component
    end

    def new
        redirect_to wizard_path(steps.first, component_id: @component.id)
    end

    def finish_wizard_path
        edit_notification_path(@component.notification)
    end

private

    def component_params
        params.require(:component).permit()
    end

    def set_component
        @component = Component.find(params[:component_id])
    end
end
