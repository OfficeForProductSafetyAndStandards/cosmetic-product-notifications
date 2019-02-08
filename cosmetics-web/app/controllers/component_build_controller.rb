class ComponentBuildController < ApplicationController
  include Wicked::Wizard

  steps :number_of_shades, :add_shades

  before_action :set_component

  def show
    @component.shades = ['', ''] if step == :add_shades && @component.shades.nil?
    render_wizard
  end

  def update
    case step
    when :number_of_shades
      case params[:number_of_shades]
      when "single"
        @component.shades = nil
        @component.save
        redirect_to finish_wizard_path
      when "multiple"
        render_wizard @component
      when ""
        @component.errors.add :shades, "Please select an option"
        render step
      end
    when :add_shades
      render_add_shades
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

  def render_add_shades
    @component.update(component_params)

    if params.key?(:add_shade) && params[:add_shade]
      @component.shades.push ''
      render :add_shades
    elsif params.key?(:remove_shade_with_id)
      @component.shades.delete_at(params[:remove_shade_with_id].to_i)
      if @component.shades.length < 2
        @component.shades.push ''
      end
      render :add_shades
    else
      @component.prune_blank_shades
      if @component.valid?
        render_wizard @component
      else
        if @component.shades.length < 2
          required_shades = 2 - @component.shades.length
          @component.shades.concat(Array.new(required_shades, ''))
        end
        render step
      end
    end
  end
end
