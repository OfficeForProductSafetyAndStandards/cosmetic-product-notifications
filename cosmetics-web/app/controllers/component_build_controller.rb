class ComponentBuildController < ApplicationController
  include Wicked::Wizard
  include NanoMaterialsHelper
  include CategoryHelper

  steps :add_component_name,
        :number_of_shades,
        :add_shades,
        :add_cmrs,
        :contains_nanomaterials,
        :add_nanomaterial,
        :select_category,
        :select_formulation_type,
        :select_frame_formulation,
        :upload_formulation

  before_action :set_component

  def show
    @component.shades = ['', ''] if step == :add_shades && @component.shades.nil?
    if step == :add_cmrs && @component.cmrs.size < NUMBER_OF_CMRS
      cmrs_needed = NUMBER_OF_CMRS - @component.cmrs.size
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
    when :select_formulation_type
      render_select_formulation_type
    when :select_frame_formulation
      render_select_frame_formulation
    when :upload_formulation
      render_upload_formulation
    else
      @component.update(component_params)
      render_wizard @component
    end
  end

  def new
    if @component.notification.is_multicomponent?
      redirect_to wizard_path(steps.first, component_id: @component.id)
    else
      redirect_to wizard_path(:number_of_shades, component_id: @component.id)
    end
  end

  def finish_wizard_path
    new_responsible_person_notification_component_trigger_question_path(@component.notification.responsible_person, @component.notification, @component)
  end

private

  NUMBER_OF_CMRS = 10

  def set_component
    @component = Component.find(params[:component_id])
    authorize @component.notification, policy_class: ResponsiblePersonNotificationPolicy
  end

  def component_params
    params.require(:component).permit(:name, :sub_sub_category, :notification_type, :frame_formulation, shades: [])
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
      @component.nano_material = NanoMaterial.create if @component.nano_material.nil?
      render_wizard @component
    when "no"
      @component.nano_material = nil
      redirect_to wizard_path(:select_category, component_id: @component.id)
    when ""
      @component.errors.add :nano_materials, "Please select an option"
      render step
    end
  end

  def render_add_nanomaterial
    if nano_elements_not_selected
      @no_nano_element_selected = true
    end
    if params[:nano_material_exposure_route].nil?
      @no_exposure_route_selected = true
    end
    if params[:nano_material_exposure_condition].nil?
      @no_exposure_condition_selected = true
    end

    if @no_nano_element_selected || @no_exposure_route_selected || @no_exposure_condition_selected
      return render step
    end

    selected_exposure_route = exposure_routes[params[:nano_material_exposure_route].to_i]
    selected_exposure_condition = exposure_conditions[params[:nano_material_exposure_condition].to_i]

    @component.nano_material.update(exposure_condition: selected_exposure_condition, exposure_route: selected_exposure_route)

    @component.nano_material.nano_elements.destroy_all
    nano_elements.each do |key, nano_element|
      if params[key.to_sym] == "1"
        @component.nano_material.nano_elements.create(nano_element)
      end
    end

    render_wizard @component
  end

  def nano_elements_not_selected
    nano_elements.each do |key, _nano_element|
      return false if params[key.to_sym] == "1"
    end
    true
  end

  def render_add_cmrs
    cmrs = params[:cmrs]
    cmrs.each do |index, cmr|
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

  def render_select_formulation_type
    if params[:component].nil?
      @no_notification_type_selected = true
      return render step
    end
    @component.update(component_params)
    if @component.predefined?
      @component.formulation_file.delete if @component.formulation_file.attached?
      render_wizard @component
    else
      @component.update(frame_formulation: nil) unless @component.frame_formulation.nil?
      redirect_to wizard_path(:upload_formulation, component_id: @component.id)
    end
  end

  def render_select_frame_formulation
    @component.update(component_params)
    redirect_to finish_wizard_path
  end

  def render_upload_formulation
    if params[:formulation_file].present?
      file_upload = params[:formulation_file]
      @component.formulation_file.attach(file_upload)
      redirect_to finish_wizard_path
    else
      @component.errors.add :formulation_file, "Please upload a file"
      render step
    end
  end
end
