class ComponentBuildController < ApplicationController
  include Wicked::Wizard
  include NanoMaterialsHelper
  include CategoryHelper

  steps :number_of_shades,
        :add_shades,
        :add_cmrs,
        :contains_nanomaterials,
        :add_nanomaterial,
        :select_category

  before_action :set_component

  def show
    @component.shades = ['', ''] if step == :add_shades && @component.shades.nil?
    if step == :add_cmrs && @component.cmrs.size < 3
      cmrs_needed = 3 - @component.cmrs.size
      cmrs_needed.times { @component.cmrs.create(name: '', cas_number: '') }
    end
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
    when :add_nanomaterial
      render_add_nanomaterial
    when :add_cmrs
      render_add_cmrs
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
    params.require(:component).permit(:sub_sub_category, shades: [])
  end

  def render_number_of_shades
    case params[:number_of_shades]
    when "single"
      @component.shades = nil
      @component.add_shades
      @component.save
      redirect_to wizard_path(:add_cmrs, component_id: @component.id)
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
      @component.nano_materials.destroy_all
      redirect_to wizard_path(:select_category, component_id: @component.id)
    when ""
      @component.errors.add :nano_materials, "Please select an option"
      render step
    end
  end

  def render_add_nanomaterial
    if params[:nano_material_index].nil?
      @no_nano_material_selected = true
    end
    if params[:nano_material_exposure_route].nil?
      @no_exposure_route_selected = true
    end
    if params[:nano_material_exposure_condition].nil?
      @no_exposure_condition_selected = true
    end

    if @no_nano_material_selected || @no_exposure_route_selected || @no_exposure_condition_selected
      return render step
    end

    selected_nano_material = nano_materials[params[:nano_material_index].to_i]
    selected_exposure_route = exposure_routes[params[:nano_material_exposure_route].to_i]
    selected_exposure_condition = exposure_conditions[params[:nano_material_exposure_condition].to_i]

    nano_material = @component.nano_materials.build(
        exposure_condition: selected_exposure_condition,
        exposure_route: selected_exposure_route
    )
    nano_material.nano_elements.build(selected_nano_material)

    render_wizard @component
  end

  def render_add_cmrs
    cmrs = params[:cmrs]
    cmrs.each do |index , cmr|
      cmr_name = cmr[:name]
      cmr_cas_number = cmr[:cas_number]

      if !cmr_name.nil? && cmr_name != '' && !cmr_cas_number.nil? && cmr_cas_number != ''
        @component.cmrs[index.to_i].update name: cmr_name, cas_number: cmr_cas_number
      else
        @component.cmrs[index.to_i].destroy
      end
    end
    render_wizard @component
  end
end
