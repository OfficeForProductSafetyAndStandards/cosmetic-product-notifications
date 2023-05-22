require "csv"

class ResponsiblePersons::Notifications::Components::BuildController < SubmitApplicationController
  include Wicked::Wizard
  include WizardConcern
  include CategoryHelper

  before_action :set_component
  before_action :set_category, if: -> { step.to_s =~ /select_(root|sub|sub_sub)_category/ }

  steps :add_component_name,
        # This step is included only when nanomaterials are defined
        # in the task list
        :select_nanomaterials,
        :after_select_nanomaterials_routing,
        :add_exposure_condition,
        :add_exposure_routes,
        :number_of_shades,
        :add_shades,
        :add_physical_form,
        :contains_special_applicator,
        :select_special_applicator_type, # only if contains special applicator
        :contains_cmrs,
        :add_cmrs,
        :select_root_category,
        :select_sub_category,
        :select_sub_sub_category,
        :select_formulation_type,
        :add_ingredient_exact_concentration, # only for exact
        :add_ingredient_range_concentration, # only for range
        :upload_ingredients_file,
        :select_frame_formulation, # only for frame formulation
        :contains_ingredients_npis_needs_to_know, # only for frame formulation
        :add_ingredient_npis_needs_to_know, # only for frame formulation
        :want_to_add_another_ingredient,
        :select_ph_option,
        :completed

  BACK_ROUTING = {
    select_nanomaterials: {
      add_component_name: -> { @component.notification.multi_component? },
    },
    add_exposure_condition: :select_nanomaterials,
    add_exposure_routes: :add_exposure_condition,
    number_of_shades: {
      add_exposure_routes: -> { @component.nano_materials.present? },
      select_nanomaterials: -> { @component.notification.nano_materials.present? },
      add_component_name: -> { @component.notification.multi_component? },
    },
    add_shades: :number_of_shades,
    add_physical_form: :number_of_shades,
    contains_special_applicator: :add_physical_form,
    select_special_applicator_type: :contains_special_applicator, # only if contains special applicator,
    contains_cmrs: :contains_special_applicator,
    add_cmrs: :contains_cmrs,
    select_root_category: :contains_cmrs,
    select_sub_category: :select_root_category,
    select_sub_sub_category: :select_sub_category,
    select_formulation_type: :select_sub_sub_category,
    add_ingredient_exact_concentration: :select_formulation_type,
    add_ingredient_range_concentration: :select_formulation_type,
    upload_ingredients_file: :select_formulation_type,
    want_to_add_another_ingredient: :select_formulation_type,
    select_frame_formulation: :select_formulation_type, # only for frame formulation,
    contains_ingredients_npis_needs_to_know: :select_formulation_type, # only for frame formulation,
    add_ingredient_npis_needs_to_know: :contains_ingredients_npis_needs_to_know, # only for frame formulation,
    select_ph_option: {
      select_formulation_type: -> { @component.exact? || @component.range? },
      contains_ingredients_npis_needs_to_know: -> { @component.predefined? },
    },
  }.freeze

  def show
    case step
    when :select_nanomaterials
      return jump_to_step(:number_of_shades) if @component.notification.nano_materials.blank?
    when :add_shades
      @component.shades = ["", ""] if @component.shades.blank?
    when :add_cmrs
      create_required_cmrs
    when :after_select_nanomaterials_routing
      if @component.nano_materials.present?
        return render_next_step(@component)
      else
        return jump_to_step(:number_of_shades)
      end
    when :add_ingredient_exact_concentration, :add_ingredient_range_concentration, :add_ingredient_npis_needs_to_know
      create_required_ingredients
    when :upload_ingredients_file
      @bulk_ingredients_form = ResponsiblePersons::Notifications::Components::BulkIngredientUploadForm.new(component: @component, current_user:)
    when :want_to_add_another_ingredient
      @success_banner = ActiveModel::Type::Boolean.new.cast(params[:success_banner])
    when :select_ph_option
      return jump_to_step(:completed) unless @component.ph_required?
    when :completed
      @component.complete!
      return render template: "responsible_persons/notifications/task_completed", locals: { continue_path: }
    end

    render_wizard
  end

  def update
    case step
    when :select_nanomaterials
      update_select_nanomaterials
    when :add_exposure_routes
      update_add_exposure_routes
    when :number_of_shades
      update_number_of_shades
    when :add_shades
      update_add_shades
    when :contains_special_applicator
      update_contains_special_applicator
    when :contains_cmrs
      update_contains_cmrs
    when :add_cmrs
      update_add_cmrs
    when :select_root_category
      update_select_category_step
    when :select_sub_category
      update_select_category_step
    when :select_sub_sub_category
      update_select_category_step
    when :select_formulation_type
      update_select_formulation_type
    when :add_ingredient_exact_concentration
      update_add_ingredients
    when :add_ingredient_range_concentration
      update_add_ingredients
    when :add_ingredient_npis_needs_to_know
      update_add_ingredients
    when :upload_ingredients_file
      update_upload_ingredients_file
    when :select_frame_formulation
      update_frame_formulation
    when :contains_ingredients_npis_needs_to_know
      update_contains_ingredients_npis_needs_to_know
    when :want_to_add_another_ingredient
      update_want_to_add_another_ingredient
    when :select_ph_option
      update_select_component_ph_options
    else
      # Apply this since render_wizard(@component, context: :context) doesn't work as expected
      if @component.update_with_context(component_params, step)
        render_next_step @component
      else
        rerender_current_step
      end
    end
  end

  def new
    if @component.notification.is_multicomponent?
      redirect_to wizard_path(steps.first, component_id: @component.id)
    elsif @component.notification.nano_materials.present?
      redirect_to wizard_path(:select_nanomaterials, component_id: @component.id)
    else
      redirect_to wizard_path(:number_of_shades, component_id: @component.id)
    end
  end

private

  def continue_path
    components = @notification.components.order(:created_at)
    next_component_index = components.find_index { |c| c.id == params[:component_id].to_i }.next

    if components[next_component_index]
      new_responsible_person_notification_component_build_path(@notification.responsible_person, @notification, components[next_component_index])
    else
      review_responsible_person_notification_draft_path(@notification.responsible_person, @notification)
    end
  end

  def update_number_of_shades
    answer = params.dig(:component, :number_of_shades)

    model.save_routing_answer(step, answer)
    case answer
    when "single-or-no-shades", "multiple-shades-different-notification"
      @component.shades = nil
      jump_to_step :add_physical_form
    when "multiple-shades-same-notification"
      render_next_step @component
    else
      @component.errors.add :number_of_shades, "Select yes if the product is available in shades"
      rerender_current_step
    end
  end

  def update_select_nanomaterials
    ids = params.dig(:component, :nano_material_ids)
    if @component.update(nano_material_ids: (ids || []))
      render_next_step @component
    else
      rerender_current_step
    end
  end

  def update_add_exposure_routes
    exposure_routes = params.fetch(:component, {}).select { |_key, value| value == "1" }.keys
    if @component.update_with_context({ exposure_routes: }, step)
      render_next_step @component
    else
      rerender_current_step
    end
  end

  def update_add_shades
    if @component.update_with_context(component_params, step)
      if params[:add_shade]
        @component.shades.push ""
        rerender_current_step
      elsif params.key?(:remove_shade_with_id)
        @component.shades.delete_at(params[:remove_shade_with_id].to_i)
        create_required_shades
        rerender_current_step
      else
        render_next_step @component
      end
    else
      create_required_shades
      rerender_current_step
    end
  end

  def update_contains_special_applicator
    yes_no_question(:contains_special_applicator, on_skip: proc { @component.special_applicator = nil })
  end

  def update_contains_cmrs
    yes_no_question(:contains_cmrs, on_skip: method(:destroy_all_cmrs))
  end

  def update_add_cmrs
    if @component.update_with_context(component_params, step)
      if params[:add_cmr]
        @component.cmrs.build
        rerender_current_step
      elsif params.key?(:remove_cmr_with_id)
        @component.cmrs.find(params[:remove_cmr_with_id].to_i).destroy unless params[:remove_cmr_with_id] == "unsaved"
        @component.cmrs.reload
        rerender_current_step
      else
        render_next_step @component
      end
    else
      create_required_cmrs
      rerender_current_step
    end
  end

  def update_select_category_step
    sub_category = params.dig(:component, :sub_category)
    if sub_category
      if has_sub_categories(sub_category)
        render_wizard @component, {}, category: sub_category
      else
        @component.update(sub_sub_category: sub_category)
        render_next_step @component
      end
    else
      @component.errors.add :sub_category, "Choose an option"
      rerender_current_step
    end
  end

  def update_select_formulation_type
    formulation_type = params.dig(:component, :notification_type)
    model.save_routing_answer(step, formulation_type)
    @component.update_formulation_type(formulation_type)
    return rerender_current_step if @component.errors.present?

    step = {
      "predefined" => :select_frame_formulation,
      "exact" => :add_ingredient_exact_concentration,
      "range" => :add_ingredient_range_concentration,
      "exact_csv" => :upload_ingredients_file,
      "range_csv" => :upload_ingredients_file,
    }[formulation_type]

    if @component.ingredients.any? && !@component.predefined?
      jump_to_step(step, ingredient_number: 0) # Display first existing ingredient for edit
    else
      jump_to_step(step)
    end
  end

  # for frame formulation only
  def update_frame_formulation
    if @component.update_with_context(component_params, :select_frame_formulation)
      jump_to_step :contains_ingredients_npis_needs_to_know
    else
      render :select_frame_formulation
    end
  end

  def update_upload_ingredients_file
    ingredients_file = params.dig(:responsible_persons_notifications_components_bulk_ingredient_upload_form, :file)

    @bulk_ingredients_form = ResponsiblePersons::Notifications::Components::BulkIngredientUploadForm.new(component: @component, file: ingredients_file, current_user:)

    if ingredients_file.nil? && @component.ingredients_file.present?
      return jump_to_step :select_ph_option
    end

    if @bulk_ingredients_form.save_ingredients
      @component.ingredients_file.attach(ingredients_file)
      # we actually want to re-render current step with parameter saying that all went well
      @ingredients_imported = true
    end

    rerender_current_step
  end

  def update_contains_ingredients_npis_needs_to_know
    model.save_routing_answer(step, params.dig(:component, :contains_ingredients_npis_needs_to_know))

    if params.fetch(:component, {})[:contains_ingredients_npis_needs_to_know].blank?
      @component.errors.add(:contains_ingredients_npis_needs_to_know,
                            "Select yes if the product contains ingredients the NPIS needs to know about")
      return render :contains_ingredients_npis_needs_to_know
    end

    @component.update!(contains_poisonous_ingredients: params[:component][:contains_ingredients_npis_needs_to_know])
    if @component.contains_poisonous_ingredients?
      jump_to(:add_ingredient_npis_needs_to_know, ingredient_number: 0) if @component.ingredients.any?
    else
      jump_to(:select_ph_option)
    end
    render_next_step @component
  end

  def update_add_ingredients
    if @component.update_with_context(component_params, step)
      if params[:add_ingredient]
        @component.ingredients.build(poisonous: nil)
        rerender_current_step
      elsif params.key?(:remove_ingredient_with_id)
        @component.ingredients.find(params[:remove_ingredient_with_id].to_i).destroy unless params[:remove_ingredient_with_id] == "unsaved"
        @component.ingredients.reload
        rerender_current_step
      else
        jump_to_step(:select_ph_option)
      end
    else
      create_required_ingredients
      rerender_current_step
    end
  end

  def update_select_component_ph_options
    if @component.update_with_context(component_params, :ph)
      jump_to :completed
      render_next_step @component
    else
      rerender_current_step
    end
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
        :sub_sub_category,
        :frame_formulation,
        :ph,
        :lower_than_3_minimum_ph,
        :lower_than_3_maximum_ph,
        :above_10_minimum_ph,
        :above_10_maximum_ph,
        :exposure_condition,
        nano_material_ids: [],
        exposure_routes: [],
        cmrs_attributes: %i[id name cas_number ec_number],
        ingredients_attributes:,
        shades: [],
      )
  end

  def ingredients_attributes
    %i[
      id
      inci_name
      used_for_multiple_shades
      exact_concentration
      maximum_exact_concentration
      minimum_concentration
      maximum_concentration
      range_concentration
      cas_number
      poisonous
    ]
  end

  def create_required_shades
    if @component.shades.length < 2
      required_shades = 2 - @component.shades.length
      @component.shades.concat(Array.new(required_shades, ""))
    end
  end

  def create_required_cmrs
    @component.cmrs.build if @component.cmrs.blank?
  end

  def create_required_ingredients
    # set poisonous to nil so the radio buttons are not pre-selected
    @component.ingredients.build(poisonous: nil) if @component.ingredients.blank?
  end

  def model
    @component
  end

  def destroy_all_cmrs
    @component.cmrs.destroy_all
  end

  def set_category
    @category = params[:category]
    if @category.nil? && step == :select_sub_sub_category
      @category = @component.sub_category
    end
    if @category.nil? && step == :select_sub_category
      @category = Component.get_parent_category(@component.sub_category)
    end
    if @category.present? && !has_sub_categories(@category)
      @component.errors.add :sub_category, "Select a valid option"
      @category = nil
    end
    @sub_categories = @category.present? ? get_sub_categories(@category) : get_main_categories
    @selected_sub_category = @sub_categories.find { |category| @component.belongs_to_category?(category) }
  end

  def minimum_state
    NotificationStateConcern::READY_FOR_COMPONENTS
  end
end
