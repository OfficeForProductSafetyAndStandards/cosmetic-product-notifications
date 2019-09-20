class ComponentBuildController < ApplicationController
  include Wicked::Wizard
  include CategoryHelper
  include ManualNotificationConcern

  steps :add_component_name,
        :number_of_shades,
        :add_shades,
        :add_physical_form,
        :contains_special_applicator,
        :select_special_applicator_type,
        :contains_cmrs,
        :add_cmrs,
        :contains_nanomaterials,
        :add_exposure_condition,
        :add_exposure_routes,
        :list_nanomaterials,
        :select_category,
        :select_formulation_type,
        :upload_formulation,
        :select_frame_formulation

  before_action :set_component
  before_action :set_nano_material
  before_action :set_category, if: -> { step == :select_category }

  def show
    case step
    when :add_shades
      @component.shades = ['', ''] if @component.shades.nil?
    when :add_cmrs
      create_required_cmrs
    when :list_nanomaterials
      setup_nano_elements
    end
    render_wizard
  end

  def update
    case step
    when :number_of_shades
      render_number_of_shades
    when :add_shades
      render_add_shades
    when :contains_special_applicator
      render_contains_special_applicator
    when :contains_cmrs
      render_contains_cmrs
    when :add_cmrs
      render_add_cmrs
    when :contains_nanomaterials
      render_contains_nanomaterials
    when :add_exposure_routes
      render_add_exposure_routes
    when :list_nanomaterials
      render_list_nanomaterials
    when :select_category
      render_select_category_step
    when :select_formulation_type
      render_select_formulation_type
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
    previous_step = previous_step(previous_step) if skip_step?(previous_step)

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
    responsible_person_notification_component_trigger_question_path(@component.notification.responsible_person, @component.notification, @component, :select_ph_range)
  end

private

  NUMBER_OF_CMRS = 5
  NUMBER_OF_NANO_MATERIALS = 10

  def set_component
    @component = Component.find(params[:component_id])
    authorize @component.notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
    @component_name = @component.notification.is_multicomponent? ? @component.name : "the cosmetic product"
  end

  def set_nano_material
    @nano_material = @component.nano_material
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

  def component_params
    params.fetch(:component, {})
      .permit(
        :name,
        :physical_form,
        :special_applicator,
        :other_special_applicator,
        :sub_sub_category,
        :notification_type,
        :frame_formulation,
        nano_material_attributes: %i[id exposure_condition],
        cmrs_attributes: %i[id name cas_number ec_number],
        shades: []
      )
  end

  def nano_material_params
    params.fetch(:nano_material, {})
      .permit(nano_elements_attributes: %i[id inci_name])
  end

  def render_number_of_shades
    case params.dig(:component, :number_of_shades)
    when "single-or-no-shades", "multiple-shades-different-notification"
      @component.shades = nil
      @component.add_shades
      jump_to(next_step(:add_shades))
      render_wizard @component
    when "multiple-shades-same-notification"
      render_wizard @component
    else
      @component.errors.add :number_of_shades, "Please select an option"
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
      create_required_shades
      render :add_shades
    else
      @component.prune_blank_shades
      if @component.valid?
        render_wizard @component
      else
        create_required_shades
        render step
      end
    end
  end

  def render_contains_special_applicator
    yes_no_question(:contains_special_applicator, before_skip: Proc.new { @component.special_applicator = nil })
  end

  def render_contains_cmrs
    yes_no_question(:contains_cmrs, before_skip: method(:destroy_all_cmrs))
  end

  def render_add_cmrs
    if @component.update_with_context(component_params, step)
      render_wizard @component
    else
      create_required_cmrs
      render step
    end
  end

  def render_contains_nanomaterials
    yes_no_question(:contains_nanomaterials,
                    before_skip: Proc.new { @nano_material.destroy if @nano_material.present? },
                    before_render: Proc.new { @component.nano_material = NanoMaterial.create if @nano_material.nil? },
                    steps_to_skip: 3)
  end

  def render_add_exposure_routes
    exposure_routes = params[:nano_material].select { |_key, value| value == "1" }.keys
    if @nano_material.update_with_context({ exposure_routes: exposure_routes }, step)
      render_wizard @component
    else
      render step
    end
  end

  def render_list_nanomaterials
    @nano_material.update(nano_material_params)

    @nano_material.nano_elements.each do |nano_element|
      NanoElement.delete(nano_element) if nano_element.inci_name.blank?
    end
    @nano_material.reload

    if @nano_material.nano_elements.any?
      start_to_nano_elements_journey
    else
      @nano_material.errors.add :nano_elements, "No nano-material added"
      setup_nano_elements
      render step
    end
  end

  def start_to_nano_elements_journey
    nano_element = @nano_material.nano_elements.first
    redirect_to new_responsible_person_notification_component_nanomaterial_build_path(@component.notification.responsible_person, @component.notification, @component, nano_element)
  end

  def render_select_category_step
    sub_category = params.dig(:component, :sub_category)
    if sub_category
      if has_sub_categories(sub_category)
        redirect_to responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, category: sub_category)
      else
        @component.update(sub_sub_category: sub_category)
        render_wizard @component
      end
    else
      @component.errors.add :sub_category, "Choose an option"
      render step
    end
  end

  def render_select_formulation_type
    unless @component.update_with_context(component_params, step)
      return render step
    end

    if @component.predefined?
      @component.formulation_file.delete if @component.formulation_file.attached?
      jump_to(next_step(:upload_formulation))
    else
      @component.update(frame_formulation: nil) unless @component.frame_formulation.nil?
    end
    render_wizard @component
  end

  def render_upload_formulation
    formulation_file = params.dig(:component, :formulation_file)

    if formulation_file.present?
      @component.formulation_file.attach(formulation_file)
      if @component.valid?
        redirect_to finish_wizard_path
      else
        @component.formulation_file.delete if @component.formulation_file.attached?
        render step
      end
    else
      @component.errors.add :formulation_file, "Please upload a file"
      render step
    end
  end

  def setup_nano_elements
    nano_materials_needed = NUMBER_OF_NANO_MATERIALS - @nano_material.nano_elements.size
    nano_materials_needed.times { @nano_material.nano_elements.build(inci_name: '') }
  end

  def get_previous_step
    case step
    when :add_physical_form
      @component.shades.present? ? :add_shades : :number_of_shades
    when :contains_nanomaterials
      @component.cmrs.present? ? :add_cmrs : :contains_cmrs
    when :contains_cmrs
      @component.special_applicator.present? ? :select_special_applicator_type : :contains_special_applicator
    when :select_category
      @component.nano_material.present? ? :list_nanomaterials : :contains_nanomaterials
    when :select_frame_formulation
      :select_formulation_type
    end
  end

  def create_required_shades
    if @component.shades.length < 2
      required_shades = 2 - @component.shades.length
      @component.shades.concat(Array.new(required_shades, ''))
    end
  end

  def create_required_cmrs
    if @component.cmrs.size < NUMBER_OF_CMRS
      cmrs_needed = NUMBER_OF_CMRS - @component.cmrs.size
      cmrs_needed.times { @component.cmrs.build }
    end
  end

  def destroy_all_cmrs
    @component.cmrs.destroy_all
  end

  def post_eu_exit_steps
    %i[add_cmrs contains_cmrs contains_special_applicator select_special_applicator_type]
  end

  def model
    @component
  end
end
