class ResponsiblePersons::Notifications::ProductController < SubmitApplicationController
  include Wicked::Wizard
  include WizardConcern

  steps :add_product_name,
        :add_internal_reference,
        :for_children_under_three,
        :contains_nanomaterials,
        :single_or_multi_component,
        :add_product_image,
        :completed

  BACK_ROUTING = {
    add_internal_reference: :add_product_name,
    for_children_under_three: :add_internal_reference,
    contains_nanomaterials: :for_children_under_three,
    single_or_multi_component: :contains_nanomaterials,
    add_product_image: :single_or_multi_component,
  }.freeze

  before_action :set_notification_and_authorize
  before_action :check_notification_submitted
  before_action :contains_nanomaterials_form, if: -> { step == :contains_nanomaterials }
  before_action :single_or_multi_component_form, if: -> { step == :single_or_multi_component }

  def show
    case step
    when :completed
      @notification.set_state_on_product_wizard_completed!
      @continue_path = continue_path
      render template: "responsible_persons/notifications/task_completed", locals: { continue_path: @continue_path }
    when :add_product_image
      @clone_image_job = NotificationCloner::JobTracker.new(@notification.id) if @notification.cloned?
      render_wizard
    else
      render_wizard
    end
  end

  def update
    case step
    when :add_internal_reference
      update_add_internal_reference
    when :contains_nanomaterials
      update_contains_nanomaterials
    when :single_or_multi_component
      update_single_or_multi_component_step
    when :add_product_image
      @clone_image_job = NotificationCloner::JobTracker.new(@notification.id) if @notification.cloned?
      update_add_product_image_step
    else
      update_column_or_fallback
    end
  end

  def new
    redirect_to wizard_path(steps.first)
  end

private

  def set_notification_and_authorize
    base_query = Notification
      .select(selected_notification_columns + responsible_person_columns)
      .joins(:responsible_person)

    base_query = case step
                 when :contains_nanomaterials, :completed
                   base_query.includes(:nano_materials, :components)
                 when :single_or_multi_component
                   base_query.includes(:components)
                 else
                   base_query
                 end

    @notification = base_query.find_by!(reference_number: params[:notification_reference_number])

    @responsible_person = @notification.responsible_person

    session_key = "authorized_for_notification_#{@notification.id}"
    unless session[session_key]
      authorized = ResponsiblePersonUser.exists?(
        user_id: current_user.id,
        responsible_person_id: @notification.responsible_person_id,
      )
      raise Pundit::NotAuthorizedError unless authorized

      session[session_key] = true
    end
  end

  def check_notification_submitted
    return unless @notification.state == "notification_complete" && @notification.notification_complete_at.present?

    redirect_to responsible_person_notification_path(@notification.responsible_person, @notification)
  end

  def continue_path
    @continue_path ||= if @notification.nano_materials.any?
                         new_responsible_person_notification_nanomaterial_build_path(@responsible_person, @notification, @notification.nano_materials.first)
                       elsif @notification.multi_component?
                         new_responsible_person_notification_product_kit_path(@responsible_person, @notification)
                       else
                         component = @notification.components.first || @notification.components.create!
                         new_responsible_person_notification_component_build_path(@responsible_person, @notification, component)
                       end
  end

  def update_with_context_and_render
    if @notification.update_with_context(notification_params, step)
      render_next_step @notification
    else
      rerender_current_step
    end
  end

  def update_add_internal_reference
    case params.dig(:notification, :add_internal_reference)
    when "yes"
      @notification.transaction do
        model.save_routing_answer(step, "yes")
        if @notification.update_with_context(notification_params, step)
          render_next_step @notification
        else
          rerender_current_step
        end
      end
    when "no"
      @notification.transaction do
        model.save_routing_answer(step, "no")
        @notification.update_column(:industry_reference, nil)
        render_next_step @notification
      end
    else
      @notification.errors.add :add_internal_reference, "Select yes to add an internal reference"
      rerender_current_step
    end
  end

  def update_contains_nanomaterials
    return render_next_step @notification if @notification.nano_materials.loaded? ? @notification.nano_materials.any? : @notification.nano_materials.exists?

    form = contains_nanomaterials_form
    return rerender_current_step unless form.valid?

    @notification.transaction do
      model.save_routing_answer(step, form.contains_nanomaterials)
      @notification.make_ready_for_nanomaterials!(form.nanomaterials_count.to_i)
      render_next_step @notification
    end
  end

  def update_single_or_multi_component_step
    return render_next_step @notification if @notification.multi_component?

    form = single_or_multi_component_form
    return rerender_current_step unless form.valid?

    @notification.transaction do
      @notification.make_single_ready_for_components!(form.components_count.to_i)
      render_next_step @notification
    end
  end

  def update_add_product_image_step
    if params[:image_upload].present?
      params[:image_upload].each { |img| @notification.add_image(img) }
      return rerender_current_step if @notification.errors.present?

      @notification.save!
      handle_existing_image_uploads
    elsif @notification.image_uploads.present?
      handle_existing_image_uploads
    else
      @notification.errors.add :image_uploads, "Select an image"
      rerender_current_step
    end
  end

  def handle_existing_image_uploads
    if params[:back_to_edit] == "true"
      redirect_to edit_responsible_person_notification_path(@notification.responsible_person, @notification)
    elsif params[:after_save] == "upload_another"
      rerender_current_step
    else
      render_next_step @notification
    end
  end

  def notification_params
    params.fetch(:notification, {})
      .permit(
        :product_name,
        :industry_reference,
        :under_three_years,
        :still_on_the_market,
        :shades,
        :import_country,
        :cpnp_notification_date,
        :was_notified_before_eu_exit,
        image_uploads_attributes: [file: []],
      )
  end

  def contains_nanomaterials_params
    params.fetch(:contains_nanomaterials_form, {})
          .permit(:contains_nanomaterials, :nanomaterials_count)
  end

  def single_or_multi_component_params
    params.fetch(:single_or_multi_component_form, {})
          .permit(:single_or_multi_component, :components_count)
  end

  def contains_nanomaterials_form
    @contains_nanomaterials_form ||=
      ResponsiblePersons::Notifications::Product::ContainsNanomaterialsForm.new(contains_nanomaterials_params)
  end

  def single_or_multi_component_form
    @single_or_multi_component_form ||=
      ResponsiblePersons::Notifications::Product::SingleOrMultiComponentForm.new(single_or_multi_component_values)
  end

  def single_or_multi_component_values
    return single_or_multi_component_params if single_or_multi_component_params.keys.any?

    count = @notification.components.count
    case count
    when 0
      {}
    when 1
      { single_or_multi_component: ResponsiblePersons::Notifications::Product::SingleOrMultiComponentForm::SINGLE,
        components_count: count }
    else
      { single_or_multi_component: ResponsiblePersons::Notifications::Product::SingleOrMultiComponentForm::MULTI,
        components_count: count }
    end
  end

  def model
    @notification
  end

  def rerender_current_step
    render step
  end

  def selected_notification_columns
    %i[
      id
      reference_number
      product_name
      state
      notification_complete_at
      responsible_person_id
      industry_reference
      under_three_years
      components_are_mixed
      previous_state
      routing_questions_answers
      cpnp_reference
      source_notification_id
      archive_reason
      import_country
      shades
      cpnp_notification_date
      was_notified_before_eu_exit
      still_on_the_market
      ph_min_value
      ph_max_value
      csv_cache
      deleted_at
    ]
  end

  def responsible_person_columns
    [
      Arel.sql("responsible_persons.id as responsible_person_id"),
      Arel.sql("responsible_persons.name as responsible_person_name"),
    ]
  end

  def update_column_or_fallback
    direct_update_columns = {
      product_name: true,
      under_three_years: true,
      industry_reference: ->(_params) { step != :add_internal_reference },
      still_on_the_market: true,
      shades: true,
      import_country: true,
      cpnp_notification_date: true,
      was_notified_before_eu_exit: true,
    }

    direct_update_columns.each do |column, condition|
      next unless notification_params.key?(column)
      next unless condition.is_a?(Proc) ? condition.call(notification_params) : condition

      return perform_direct_column_update(column)
    end

    @notification.transaction do
      if @notification.update_with_context(notification_params, step)
        render_next_step @notification
      else
        rerender_current_step
      end
    end
  end

  def perform_direct_column_update(column)
    column_updated = @notification.update_column(column, notification_params[column])
    if column_updated
      render_next_step(@notification)
    else
      @notification.errors.add(column, "could not be updated")
      rerender_current_step
    end
  end
end
