class ResponsiblePersons::Notifications::Components::DeleteIngredientsController < SubmitApplicationController
  before_action :set_component
  before_action :set_ingredient

  def show; end

  def destroy
    case params[:confirmation]
    when "no"
      redirect_to edit_ingredient_path
    when "yes"
      @component.delete_ingredient!(@ingredient)
      render :success, locals: { post_deletion_path: }
    else
      @ingredient.errors.add(:confirmation, "Select yes if you want to remove this ingredient")
      render :show
    end
  end

private

  def post_deletion_path
    # If no ingredients left, go to pre-adding ingredients component building wizard question.
    if @component.ingredients.none?
      step = @component.predefined? ? :contains_ingredients_npis_needs_to_know : :select_formulation_type
      component_build_path(step)
    # If deleted the last ingredient of the list, go to add another ingredient component building wizard question.
    elsif @ingredient_number == @component.ingredients.count
      component_build_path(:want_to_add_another_ingredient)
    # If there are more ingredients after the deleted one, go to the next ingredient edit page.
    elsif @ingredient_number < @component.ingredients.count
      edit_ingredient_path
    end
  end

  def edit_ingredient_path
    step = {
      "range" => :add_ingredient_range_concentration,
      "exact" => :add_ingredient_exact_concentration,
      "predefined" => :add_ingredient_npis_needs_to_know,
    }[@component.notification_type]
    component_build_path(step, ingredient_number: params[:id])
  end

  helper_method :edit_ingredient_path

  def component_build_path(step, options = {})
    responsible_person_notification_component_build_path(
      @notification.responsible_person,
      @notification,
      @component,
      step,
      **options,
    )
  end

  def set_ingredient
    @ingredient_number = params[:id]&.to_i
    @ingredient = @component.ingredients[@ingredient_number] if @ingredient_number
    return redirect_to "/404" if @ingredient.nil?
  end

  def set_component
    @component = Component.find(params[:component_id])
    @notification = @component.notification

    return redirect_to responsible_person_notification_path(@notification.responsible_person, @notification) if @notification&.notification_complete?

    authorize @notification, :update?, policy_class: ResponsiblePersonNotificationPolicy
  end
end
