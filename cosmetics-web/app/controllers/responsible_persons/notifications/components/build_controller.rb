class ResponsiblePersons::Notifications::Components::BuildController < SubmitApplicationController
  NUMBER_OF_CMRS = 5

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
        :select_frame_formulation, # only for frame formulation
        :contains_poisonous_ingredients, # only for frame formulation
        :add_poisonous_ingredient, # only for frame formulation
        :want_to_add_another_ingredient,
        :select_ph_option,
        :min_max_ph,
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
    want_to_add_another_ingredient: :select_formulation_type,
    select_frame_formulation: :select_formulation_type, # only for frame formulation,
    contains_poisonous_ingredients: :select_formulation_type, # only for frame formulation,
    add_poisonous_ingredient: :contains_poisonous_ingredients, # only for frame formulation,
    select_ph_option: {
      select_formulation_type: -> { @component.exact? || @component.range? },
      contains_poisonous_ingredients: -> { @component.predefined? },
    },
    min_max_ph: :select_ph_option,
  }.freeze

  def show
    case step
    when :select_nanomaterials
      return jump_to_step(:number_of_shades) if @component.notification.nano_materials.blank?
    when :add_shades
      @component.shades = ["", ""] if @component.shades.nil?
    when :add_cmrs
      create_required_cmrs
    when :after_select_nanomaterials_routing
      if @component.nano_materials.present?
        return render_next_step(@component)
      else
        return jump_to_step(:number_of_shades)
      end
    when :add_ingredient_exact_concentration, :add_ingredient_range_concentration, :add_poisonous_ingredient
      @ingredient_concentration_form = ingredient_concentration_form
    when :want_to_add_another_ingredient
      @success_banner = ActiveModel::Type::Boolean.new.cast(params[:success_banner])
    when :completed
      @component.update_state("component_complete")
      # TODO: write spec
      @component.reload.notification.try_to_complete_components!
      return render "responsible_persons/notifications/task_completed"
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
    when :select_category
      update_select_category_step
    when :select_root_category
      update_select_category_step
    when :select_sub_category
      update_select_category_step
    when :select_sub_sub_category
      update_select_category_step
    when :select_formulation_type
      update_select_formulation_type
    when :add_ingredient_exact_concentration
      update_add_ingredient_concentration("exact")
    when :add_ingredient_range_concentration
      update_add_ingredient_concentration("range")
    when :add_poisonous_ingredient
      update_add_ingredient_concentration("exact", force_poisonous: true)
    when :select_frame_formulation
      update_frame_formulation
    when :contains_poisonous_ingredients
      update_contains_poisonous_ingredients
    when :want_to_add_another_ingredient
      update_want_to_add_another_ingredient
    when :select_ph_option
      update_select_component_ph_options
    when :min_max_ph
      update_component_min_max_ph
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

  # TODO: add this in all flows
  def finish_wizard_path
    responsible_person_notification_draft_path(@notification.responsible_person, @notification)
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
    exposure_routes = params[:component].select { |_key, value| value == "1" }.keys
    if @component.update_with_context({ exposure_routes: exposure_routes }, step)
      render_next_step @component
    else
      rerender_current_step
    end
  end

  def update_add_shades
    @component.update(component_params)

    if params.key?(:add_shade) && params[:add_shade]
      @component.shades.push ""
      render :add_shades
    elsif params.key?(:remove_shade_with_id)
      @component.shades.delete_at(params[:remove_shade_with_id].to_i)
      create_required_shades
      render :add_shades
    else
      @component.prune_blank_shades
      if @component.valid?
        render_next_step @component
      else
        create_required_shades
        rerender_current_step
      end
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
      render_next_step @component
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
    }[@component.notification_type]

    if @component.ingredients.any? && !@component.predefined?
      jump_to_step(step, ingredient_number: 0) # Display first existing ingredient for edit
    else
      jump_to_step(step)
    end
  end

  def update_add_ingredient_concentration(type, force_poisonous: false)
    ingredient_number = ingredient_concentration_params[:ingredient_number]&.to_i
    updating_ingredient = @component.ingredients[ingredient_number] if ingredient_number

    form_attrs = ingredient_concentration_params.merge(
      component: @component, type: type, updating_ingredient: updating_ingredient,
    )
    form_attrs[:poisonous] = true if force_poisonous == true

    @ingredient_concentration_form = ResponsiblePersons::Notifications::IngredientConcentrationForm.new(form_attrs)
    if @ingredient_concentration_form.save
      # When updating an existing ingredient: Send to next ingredient page if there are more ingredients
      if ingredient_number.present? && @component.reload.ingredients.size > ingredient_number + 1
        jump_to_step(step, ingredient_number: ingredient_number + 1)
      else
        jump_to_step(:want_to_add_another_ingredient, success_banner: updating_ingredient.nil?)
      end
    else
      rerender_current_step
    end
  end

  def update_want_to_add_another_ingredient
    case params[:add_another_ingredient]
    when "yes"
      if @component.exact?
        jump_to_step(:add_ingredient_exact_concentration)
      elsif @component.range?
        jump_to_step(:add_ingredient_range_concentration)
      elsif @component.predefined?
        jump_to_step(:add_poisonous_ingredient)
      end
    when "no"
      jump_to_step(:select_ph_option)
    else
      @component.errors.add(:add_another_ingredient, "Select yes if you want to add an ingredient")
      rerender_current_step
    end
  end

  # for frame formulation only
  def update_frame_formulation
    if @component.update_with_context(component_params, :select_frame_formulation)
      jump_to_step :contains_poisonous_ingredients
    else
      render :select_frame_formulation
    end
  end

  def update_contains_poisonous_ingredients
    model.save_routing_answer(step, params.dig(:component, :contains_poisonous_ingredients))

    if params.fetch(:component, {})[:contains_poisonous_ingredients].blank?
      @component.errors.add :contains_poisonous_ingredients, "Select yes if the product contains poisonous ingredients"
      return render :contains_poisonous_ingredients
    end

    @component.update!(contains_poisonous_ingredients: params[:component][:contains_poisonous_ingredients])
    if @component.contains_poisonous_ingredients?
      jump_to(:add_poisonous_ingredient, ingredient_number: 0) if @component.ingredients.any?
    else
      jump_to(:select_ph_option)
    end
    render_next_step @component
  end

  # In views, the wording here is about range. Its confusing, as param name here is ph
  # and in next action is `ph_range`.
  def update_select_component_ph_options
    return rerender_current_step unless @component.update_with_context(component_params, :ph)

    if @component.ph_range_not_required?
      jump_to :completed
      render_next_step @component
    else
      redirect_to wizard_path(:min_max_ph)
    end
  end

  # In views, the wording here is about ph. Its confusing, as param name here is ph_range
  # and wording in previous action is about range.
  def update_component_min_max_ph
    if @component.update_with_context(component_params, :ph_range)
      jump_to_step :completed
    else
      rerender_current_step
    end
  end

  def ingredient_concentration_form
    ingredient_number = params[:ingredient_number]&.to_i
    updating_ingredient = @component.ingredients[ingredient_number] if ingredient_number
    form_attrs = ingredient_form_values(updating_ingredient, ingredient_number) if updating_ingredient
    ResponsiblePersons::Notifications::IngredientConcentrationForm.new(form_attrs)
  end

  def ingredient_form_values(ingredient, ingredient_number)
    return {} if ingredient.blank?

    { name: ingredient.inci_name,
      cas_number: ingredient.cas_number,
      exact_concentration: ingredient.exact_concentration,
      range_concentration: ingredient.range_concentration,
      poisonous: ingredient.poisonous,
      updating_ingredient: ingredient,
      ingredient_number: ingredient_number }
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
        :minimum_ph,
        :maximum_ph,
        :exposure_condition,
        nano_material_ids: [],
        exposure_routes: [],
        cmrs_attributes: %i[id name cas_number ec_number],
        shades: [],
      )
  end

  def ingredient_concentration_params
    params.fetch(:ingredient_concentration_form, {})
      .permit(
        :name,
        :exact_concentration,
        :range_concentration,
        :cas_number,
        :poisonous,
        :ingredient_number,
      )
  end

  def create_required_shades
    if @component.shades.length < 2
      required_shades = 2 - @component.shades.length
      @component.shades.concat(Array.new(required_shades, ""))
    end
  end

  def create_required_cmrs
    if @component.cmrs.size < NUMBER_OF_CMRS
      cmrs_needed = NUMBER_OF_CMRS - @component.cmrs.size
      cmrs_needed.times { @component.cmrs.build }
    end
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
