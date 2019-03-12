class ComponentBuildController < ApplicationController
  include Wicked::Wizard

  steps :number_of_shades, :add_shades, :contains_nanomaterials, :add_nanomaterial

  before_action :set_component

  def show
    @component.shades = ['', ''] if step == :add_shades && @component.shades.nil?
    render_wizard
  end

  def update
    case step
    when :number_of_shades
      render_number_of_shades
    when :add_shades
      render_add_shades
    when :contains_nanomaterials
      render_contains_nanomaterials
    else
      @component.update(component_params)
      render_wizard @component
    end
  end

  def new
    redirect_to wizard_path(steps.first, component_id: @component.id)
  end

  def finish_wizard_path
    responsible_person_notification_build_path(@component.notification.responsible_person, @component.notification, :add_product_image)
  end

private

  def set_component
    @component = Component.find(params[:component_id])
    authorize @component.notification, policy_class: ResponsiblePersonNotificationPolicy
  end

  def component_params
    params.require(:component).permit(shades: [])
  end

  def render_number_of_shades
    case params[:number_of_shades]
    when "single"
      @component.shades = nil
      @component.add_shades
      @component.save
      redirect_to wizard_path(:contains_nanomaterials, component_id: @component.id)
    when "multiple"
      render_wizard @component
    when ""
      @component.errors.add :shades, "Please select an option"
      render step
    end
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

  def render_contains_nanomaterials
    case params[:contains_nanomaterials]
    when "yes"
      render_wizard @component
    when "no"
      redirect_to finish_wizard_path
    when ""
      @component.errors.add :nano_materials, "Please select an option"
      render step
    end
  end
end
