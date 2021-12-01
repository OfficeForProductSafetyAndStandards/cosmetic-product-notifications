class ResponsiblePersons::Wizard::NotificationNanomaterialController < SubmitApplicationController
  include Wicked::Wizard
  include WizardConcern

  before_action :set_nano_element

  steps :add_nanomaterial_name,
        :select_purposes,
        :after_select_purposes_routing, # step to do routing after select purposes
        :confirm_restrictions,
        :confirm_usage,
        :after_standard_nanomaterial_routing, # step to check if non standard route needs to take place
        :non_standard_nanomaterial_notified, # when non standard
        :when_products_containing_nanomaterial_can_be_placed_on_market,
        :notify_your_nanomaterial, # FLOW TERMINATION
        :must_be_listed, # used when confirm restrictions fails - FLOW TERMINATION
        :must_conform_to_restrictions, # used when confirm usage fails - FLOW TERMINATION
        :completed

  def new
    redirect_to wizard_path(steps.first)
  end

  def show
    case step
    when :after_select_purposes_routing
      if @nano_element.non_standard? && @nano_element.purposes.one?
        return jump_to_step(:non_standard_nanomaterial_notified)
      else
        return jump_to_step(:confirm_restrictions)
      end
    when :after_standard_nanomaterial_routing
      if @nano_element.non_standard?
        return jump_to_step(:non_standard_nanomaterial_notified)
      else
        return jump_to_step(:completed)
      end
    when :completed
      @notification.reload.try_to_complete_nanomaterials!
      return render 'responsible_persons/wizard/completed'
    end

    render_wizard
  end

  def update
    case step
    when :select_purposes
      update_select_purposes_step
    when :confirm_restrictions
      update_confirm_restrictions_step
    when :confirm_usage
      update_confirm_usage_step
    when :non_standard_nanomaterial_notified
      update_non_standard_nanomaterial_step
    when :when_products_containing_nanomaterial_can_be_placed_on_market
      jump_to_step(:completed)
    else
      if @nano_element.update_with_context(nano_element_params, step)
        render_next_step @nano_element
      else
        rerender_current_step
      end
    end
  end

  private

  def set_nano_element
    @nano_element = NanoElement.find(params[:nanomaterial_nano_element_id])
    @notification = @nano_element.nano_material.notification
  end

  def nano_element_params
    params.fetch(:nano_element, {}).permit(
      :inci_name,
      :confirm_restrictions,
      :purposes,
      :confirm_usage,
      :confirm_toxicology_notified,
    )
  end

  def purpose_params
    selected_purposes = params
        .permit(nano_element: NanoElement.purposes).fetch(:nano_element, {})
        .select { |_, value| value == "1" }.keys
    { purposes: selected_purposes }
  end

  def update_select_purposes_step
    if @nano_element.update_with_context(purpose_params, step)
      render_wizard @nano_element
    else
      render step
    end
  end

  def update_confirm_restrictions_step
    confirm_restrictions = params.dig(:nano_element, :confirm_restrictions)

    @nano_element.update_with_context(nano_element_params, step)
    case confirm_restrictions
    when "yes"
      redirect_to wizard_path(:confirm_usage)
    when "no"
      redirect_to wizard_path(:must_be_listed)
    else
      @nano_element.errors.add :confirm_restrictions, "Select an option"
      render step
    end
  end

  def update_confirm_usage_step
    confirm_usage = params.dig(:nano_element, :confirm_usage)

    @nano_element.update_with_context(nano_element_params, step)
    case confirm_usage
    when "yes"
      render_next_step @nano_element
    when "no"
      jump_to(:must_conform_to_restrictions)
      render_next_step @nano_element
    else
      @nano_element.errors.add :confirm_usage, "Select an option"
      rerender_current_step
    end
  end

  def update_non_standard_nanomaterial_step
    confirm_toxicology_notified = params.dig(:nano_element, :confirm_toxicology_notified)

    @nano_element.update_with_context(nano_element_params, step)
    case confirm_toxicology_notified
    when "yes"
      jump_to_step(:when_products_containing_nanomaterial_can_be_placed_on_market)
    when "no"
      jump_to_step(:notify_your_nanomaterial)
    when "not sure"
      jump_to_step(:notify_your_nanomaterial)
    else
      @nano_element.errors.add :confirm_toxicology_notified, "Select an option"
      rerender_current_path
    end
  end

  def get_next_nano_element
    @nano_element.nano_material.nano_elements.order(:id).each_cons(2) do |element, next_element|
      return next_element if element == @nano_element
    end
  end

  private

  def model
    @nano_element
  end
end
