class ResponsiblePersons::Notifications::Components::DeleteIngredientsController < SubmitApplicationController
  before_action :set_component
  before_action :set_ingredient

  def show; end

  def destroy
    case params[:confirmation]
    when "no"
      redirect_to ingredient_path
    when "yes"
      delete_ingredient!
      render :success, locals: { post_deletion_path: post_deletion_path }
    else
      @ingredient.errors.add(:confirmation, "Select yes if you want to remove this ingredient")
      render :show
    end
  end

private

  def delete_ingredient!
    # TODO: Move this logic to the Component model once the ingredient model is unified.
    @ingredient.destroy
    @component.reload
    @component.update(notification_type: nil, state: :empty) if @component.ingredients.none?
  end

  def post_deletion_path
    if @component.ingredients.none?
      component_build_path(:select_formulation_type)
    elsif @ingredient_number == @component.ingredients.count # Deleted the last ingredient of the list
      component_build_path(:want_to_add_another_ingredient)
    elsif @ingredient_number < @component.ingredients.count
      ingredient_path
    end
  end

  def ingredient_path
    step = if @component.range?
             :add_ingredient_range_concentration
           elsif @component.exact?
             :add_ingredient_exact_concentration
           end
    component_build_path(step, ingredient_number: params[:id])
  end

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
