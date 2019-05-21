class ComponentBuildController < ApplicationController
  include Wicked::Wizard
  include NanoMaterialsHelper
  include CategoryHelper

  steps :add_component_name,
        :number_of_shades,
        :add_shades,
        :add_physical_form,
        :contains_cmrs,
        :add_cmrs,
        :contains_nanomaterials,
        :add_nanomaterial,
        :select_category,
        :select_formulation_type,
        :select_frame_formulation,
        :upload_formulation

  before_action :set_component
  before_action :set_category, if: -> { step == :select_category }

  def show
    @component.shades = ['', ''] if step == :add_shades && @component.shades.nil?
    create_required_cmrs if step == :add_cmrs
    render_wizard
  end

  def update
    case step
    when :number_of_shades
      render_number_of_shades
    when :add_shades
      render_add_shades
    when :contains_cmrs
      render_contains_cmrs
    when :add_cmrs
      render_add_cmrs
    when :contains_nanomaterials
      render_contains_nanomaterials
    when :add_nanomaterial
      render_add_nanomaterial
    when :select_category
      render_select_category_step
    when :select_formulation_type
      render_select_formulation_type
    when :select_frame_formulation
      render_select_frame_formulation
    when :upload_formulation
      render_upload_formulation
    else
      # Apply this since render_wizard(@component, context: :context) doesn't work as expected
      if @component.update_with_context(component_params, step)
        render_wizard @component
      else
        render step
      end
    end
  end

  def new
    if @component.notification.is_multicomponent?
      redirect_to wizard_path(steps.first, component_id: @component.id)
    else
      redirect_to wizard_path(:number_of_shades, component_id: @component.id)
    end
  end

  def previous_wizard_path
    previous_step = get_previous_step
    if step == :add_component_name
      responsible_person_notification_build_path(@component.notification.responsible_person, @component.notification, :add_new_component)
    elsif step == :number_of_shades && !@component.notification.is_multicomponent?
      responsible_person_notification_build_path(@component.notification.responsible_person, @component.notification, :single_or_multi_component)
    elsif step == :select_category && @category.present?
      wizard_path(:select_category, category: Component.get_parent_category(@category))
    elsif previous_step.present?
      responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, previous_step)
    else
      super
    end
  end

  def finish_wizard_path
    new_responsible_person_notification_component_trigger_question_path(@component.notification.responsible_person, @component.notification, @component)
  end

private

  NUMBER_OF_CMRS = 5

  def set_component
    @component = Component.find(params[:component_id])
    authorize @component.notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
    @component_name = @component.notification.is_multicomponent? ? @component.name : "the cosmetic product"
  end

  def component_params
    params.fetch(:component, {})
      .permit(
        :name,
        :physical_form,
        :sub_sub_category,
        :notification_type,
        :frame_formulation,
        shades: []
      )
  end

  def set_category
    @category = params[:category]
    if @category.present? && !has_sub_categories(@category)
      @component.errors.add :sub_category, "Select a valid option"
      @category = nil
    end
    @sub_categories = @category.present? ? get_sub_categories(@category) : get_main_categories
    @selected_sub_category = @sub_categories.find { |category| @component.belongs_to_category?(category) }
  end

  def render_number_of_shades
    case params[:number_of_shades]
    when "single-or-no-shades"
      @component.shades = nil
      @component.add_shades
      @component.save
      redirect_to wizard_path(:add_physical_form, component_id: @component.id)
    when "multiple-shades-different-notification"
      @component.shades = nil
      @component.add_shades
      @component.save
      redirect_to wizard_path(:add_physical_form, component_id: @component.id)
    when "multiple-shades-same-notification"
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

  def render_contains_cmrs
    case params[:contains_cmrs]
    when "yes"
      create_required_cmrs
      render_wizard @component
    when "no"
      destroy_all_cmrs
      redirect_to wizard_path(:contains_nanomaterials, component_id: @component.id)
    when ""
      @component.errors.add :cmrs, "Please select an option"
      render step
    end
  end

  def render_add_cmrs
    cmrs = params[:cmrs]
    cmrs.each do |index, cmr|
      name = cmr[:name]
      cas_number = cmr[:cas_number].delete('^0-9')
      ec_number = cmr[:ec_number].delete('^0-9')

      if !name.nil? && name != '' && !cas_number.nil? && cas_number != ''
        @component.cmrs[index.to_i].update name: name, cas_number: cas_number, ec_number: ec_number
      else
        @component.cmrs[index.to_i].destroy
      end
    end
    render_wizard @component
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

  def render_select_category_step
    sub_category = params[:component] && params[:component][:sub_category]
    if sub_category
      if has_sub_categories(sub_category)
        redirect_to responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, category: sub_category)
      else
        @component.update(sub_sub_category: sub_category)
        render_wizard @component
      end
    else
      @component.errors.add :sub_category, "Please select an option"
      render step
    end
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
    if @component.update_with_context(component_params, step)
      redirect_to finish_wizard_path
    else
      render step
    end
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

  def get_previous_step
    case step
    when :add_physical_form
      @component.shades.nil? ? :number_of_shades : :add_shades
    when :contains_nanomaterials
      @component.cmrs.empty? ? :contains_cmrs : :add_cmrs
    when :select_category
      @component.nano_material.nil? ? :contains_nanomaterials : :add_nanomaterial
    when :upload_formulation
      :select_formulation_type
    end
  end

  def create_required_cmrs
    if @component.cmrs.size < NUMBER_OF_CMRS
      cmrs_needed = NUMBER_OF_CMRS - @component.cmrs.size
      cmrs_needed.times { @component.cmrs.create(name: '', cas_number: '', ec_number: '') }
    end
  end

  def destroy_all_cmrs
    @component.cmrs.destroy_all
  end
end
