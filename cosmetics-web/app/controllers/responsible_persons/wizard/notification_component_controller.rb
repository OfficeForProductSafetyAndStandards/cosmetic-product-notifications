class ResponsiblePersons::Wizard::NotificationComponentController < SubmitApplicationController
  NUMBER_OF_CMRS = 5

  include Wicked::Wizard
  include WizardConcern
  include CategoryHelper

  before_action :set_component
  before_action :set_category, if: -> { step == :select_category }

  steps :add_component_name,
        :number_of_shades,
        :add_shades,
        :add_physical_form,
        :contains_special_applicator,
        :select_special_applicator_type, # only if contains special applicator
        :contains_cmrs,
        :add_cmrs,
        :select_category,
        :select_formulation_type,
        :upload_formulation,
        :select_frame_formulation,
        :contains_poisonous_ingredients,
        :completed

  def show
    case step
    when :add_shades
      @component.shades = ["", ""] if @component.shades.nil?
    when :add_cmrs
      create_required_cmrs
    when :completed
      @component.update(state: 'component_complete')
      # TODO: write spec
      @component.reload.notification.try_to_complete_components!
      return render 'responsible_persons/wizard/completed'
    end

    render_wizard
  end

  def update
    case step
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
    when :select_formulation_type
      update_select_formulation_type
    when :select_frame_formulation
      update_frame_formulation
    when :upload_formulation
      update_upload_formulation
    when :contains_poisonous_ingredients
      update_contains_poisonous_ingredients
    else
      # Apply this since render_wizard(@component, context: :context) doesn't work as expected
      if @component.update_with_context(component_params, step)
        render_next_step @component
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

  private

  # TODO: add this in all flows
  def finish_wizard_path
    responsible_person_notification_draft_index_path(@notification.responsible_person, @notification)
  end

  def update_number_of_shades
    case params.dig(:component, :number_of_shades)
    when "single-or-no-shades", "multiple-shades-different-notification"
      @component.shades = nil
      jump_to :add_physical_form
      render_next_step @component
    when "multiple-shades-same-notification"
      render_next_step @component
    else
      @component.errors.add :number_of_shades, "Select yes if the product is available in shades"
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
        render_wizard @component
      else
        create_required_shades
        render step
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
      render_wizard @component
    else
      create_required_cmrs
      render step
    end
  end

  def update_select_category_step
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
      rerender_current_step
    end
  end

  def update_select_formulation_type
    unless @component.update_with_context(component_params, step)
      return render step
    end

    if @component.predefined?
      @component.formulation_file.purge if @component.formulation_file.attached?
      jump_to(next_step(:upload_formulation)) # Intended target page is select_frame_formulation - assuming the step order declared above doesn't change!
    else
      @component.update(frame_formulation: nil) unless @component.frame_formulation.nil?
    end

    render_wizard @component
  end

  def update_frame_formulation
    if @component.update_with_context(component_params, :select_frame_formulation)
      redirect_to responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, :contains_poisonous_ingredients)
    else
      render :select_frame_formulation
    end
  end

  def update_contains_poisonous_ingredients
    if params.fetch(:component, {})[:contains_poisonous_ingredients].blank?
      @component.errors.add :contains_poisonous_ingredients, "Select yes if the product contains any of these ingredients"
      render :contains_poisonous_ingredients
      return
    else
      jump_to :completed
      render_next_step @component
  end

    @component.update!(contains_poisonous_ingredients: params[:component][:contains_poisonous_ingredients])
    if @component.contains_poisonous_ingredients?
      redirect_to responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, :upload_formulation)
    end
  end

  def update_upload_formulation
    formulation_file = params.dig(:component, :formulation_file)

    if formulation_file.present?
      @component.formulation_file.attach(formulation_file)
      if @component.valid?
        jump_to :completed
        render_next_step @component
      else
        @component.formulation_file.purge if @component.formulation_file.attached?
        render step
      end
    else
      @component.errors.add :formulation_file, "Upload a list of ingredients"
      render step
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
        cmrs_attributes: %i[id name cas_number ec_number],
        shades: [],
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
    if @category.present? && !has_sub_categories(@category)
      @component.errors.add :sub_category, "Select a valid option"
      @category = nil
    end
    @sub_categories = @category.present? ? get_sub_categories(@category) : get_main_categories
    @selected_sub_category = @sub_categories.find { |category| @component.belongs_to_category?(category) }
  end

end

