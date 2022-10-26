module  ResponsiblePersons::Notifications::Nanomaterials
  class BuildController < SubmitApplicationController
    include Wicked::Wizard
    include WizardConcern

    before_action :set_notification
    before_action :set_nano_material

    steps :select_purposes, # selects standard/non-standard purposes
          # Standard only steps
          :after_select_purposes_routing,
          :add_nanomaterial_name,
          :confirm_restrictions, # "Is listed in regulation?"
          :must_be_listed, # FLOW TERMINATION when confirm restrictions fails
          :confirm_usage, # "Does conform to restrictions?"
          :must_conform_to_restrictions, # FLOW TERMINATION when confirm usage fails
          # Checks if non standard route needs to take place
          :after_standard_nanomaterial_routing,
          # Non-standard only steps
          :non_standard_nanomaterial_notified, # "Have you Submited a notification since...?"
          :notify_your_nanomaterial, # FLOW TERMINATION when "Have you Submited..." fails.
          :when_products_containing_nanomaterial_can_be_placed_on_market,
          :select_notified_nanomaterial,
          :cannot_place_until_review_period_ended,
          # Common
          :completed

    # Key is current page, value is page to go back to.
    # In case of array, the first block that evaluates to true will determine back page
    BACK_ROUTING = {
      # first 3 checkboxes
      add_nanomaterial_name: :select_purposes,
      confirm_restrictions: :select_purposes,
      confirm_usage: :confirm_restrictions,
      non_standard_nanomaterial_notified: {
        confirm_usage: -> { @nano_material.multi_purpose? },
        select_purposes: -> { !@nano_material.multi_purpose? },
      },
      when_products_containing_nanomaterial_can_be_placed_on_market: :non_standard_nanomaterial_notified,
      select_notified_nanomaterial: :when_products_containing_nanomaterial_can_be_placed_on_market,
      cannot_place_until_review_period_ended: :select_notified_nanomaterial,
      notify_your_nanomaterial: {
        non_standard_nanomaterial_notified: -> { @nano_material.confirm_toxicology_notified != "yes" },
        select_notified_nanomaterial: -> { @nano_material.confirm_toxicology_notified == "yes" },
      },
      must_be_listed: :confirm_restrictions,
      must_conform_to_restrictions: :confirm_usage,
    }.freeze

    def new
      redirect_to wizard_path(steps.first)
    end

    def show
      case step
      when :select_purposes
        @purposes_form = PurposesForm.new(purposes: @nano_material.purposes)
      when :after_select_purposes_routing
        if @nano_material.non_standard? && @nano_material.purposes.one?
          return jump_to_step(:non_standard_nanomaterial_notified)
        else
          return jump_to_step(:add_nanomaterial_name)
        end
      when :after_standard_nanomaterial_routing
        if @nano_material.non_standard?
          return jump_to_step(:non_standard_nanomaterial_notified)
        else
          return jump_to_step(:completed)
        end
      when :select_notified_nanomaterial
        set_nanomaterial_notifications
      when :completed
        @notification.reload.try_to_complete_nanomaterials!
        return render "responsible_persons/notifications/task_completed"
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
      when :when_products_containing_nanomaterial_can_be_placed_on_market, :cannot_place_until_review_period_ended
        render_next_step @nano_material
      when :select_notified_nanomaterial
        update_select_notified_nanomaterial_step
      else
        if @nano_material.update_with_context(nano_material_params, step)
          render_next_step @nano_material
        else
          rerender_current_step
        end
      end
    end

  private

    def set_nano_material
      @nano_material = NanoMaterial.find(params[:nanomaterial_id])
      @notification = @nano_material.notification
    end

    def set_nanomaterial_notifications
      @nanomaterial_notifications = @notification.responsible_person.nanomaterial_notifications.submitted
    end

    def nano_material_params
      params.fetch(:nano_material, {}).permit(
        :inci_name,
        :confirm_restrictions,
        :purposes,
        :confirm_usage,
        :confirm_toxicology_notified,
      )
    end

    def purpose_params
      form_params = params.permit(purposes_form: [:purpose_type, *NanoMaterialPurposes.standard.map(&:name)])
                          .fetch(:purposes_form, {})

      { purposes: form_params.select { |_, v| v == "1" }.keys, purpose_type: form_params[:purpose_type] }
    end

    def update_select_purposes_step
      @purposes_form = PurposesForm.new(**purpose_params)
      return rerender_current_step unless @purposes_form.valid?

      attrs = { purposes: @purposes_form.purposes }
      attrs[:inci_name] = nil if @purposes_form.purposes == [NanoMaterialPurposes.other.name]

      if @nano_material.update_with_context(attrs, step)
        render_next_step @nano_material
      else
        rerender_current_step
      end
    end

    def update_confirm_restrictions_step
      confirm_restrictions = params.dig(:nano_material, :confirm_restrictions)

      @nano_material.update_with_context(nano_material_params, step)
      case confirm_restrictions
      when "yes"
        redirect_to wizard_path(:confirm_usage)
      when "no"
        redirect_to wizard_path(:must_be_listed)
      else
        @nano_material.errors.add :confirm_restrictions, "Select an option"
        rerender_current_step
      end
    end

    def update_confirm_usage_step
      confirm_usage = params.dig(:nano_material, :confirm_usage)

      @nano_material.update_with_context(nano_material_params, step)
      case confirm_usage
      when "yes"
        jump_to_step :after_standard_nanomaterial_routing
      when "no"
        jump_to_step :must_conform_to_restrictions
      else
        @nano_material.errors.add :confirm_usage, "Select an option"
        rerender_current_step
      end
    end

    def update_non_standard_nanomaterial_step
      confirm_toxicology_notified = params.dig(:nano_material, :confirm_toxicology_notified)

      @nano_material.update_with_context(nano_material_params, step)
      case confirm_toxicology_notified
      when "yes"
        jump_to_step(:when_products_containing_nanomaterial_can_be_placed_on_market)
      when "no"
        jump_to_step(:notify_your_nanomaterial)
      when "not sure"
        jump_to_step(:notify_your_nanomaterial)
      else
        @nano_material.errors.add :confirm_toxicology_notified, "Select an option"
        rerender_current_step
      end
    end

    def update_select_notified_nanomaterial_step
      set_nanomaterial_notifications
      if params[:nanomaterial_notification].blank?
        @nano_material.errors.add :nanomaterial_notification, :blank
        rerender_current_step
      else
        nanomaterial_notification = @nanomaterial_notifications.find(params[:nanomaterial_notification])
        if @nano_material.update(nanomaterial_notification:)
          if nanomaterial_notification.can_be_made_available_on_uk_market?
            jump_to_step(:completed)
          else
            jump_to_step(:cannot_place_until_review_period_ended)
          end
        else
          rerender_current_step
        end
      end
    end

    def model
      @nano_material
    end
  end
end
