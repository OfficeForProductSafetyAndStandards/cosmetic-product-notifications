class ResponsiblePersons::Wizard::NotificationComponentController < SubmitApplicationController
  NUMBER_OF_CMRS = 5

  include Wicked::Wizard
  include WizardConcern

  before_action :set_component

  steps :add_component_name,
        :number_of_shades,
        :add_shades,
        :add_physical_form,
        :contains_special_applicator,
        :select_special_applicator_type, # only if contains special applicator
        :contains_cmrs,
        :add_cmrs
        :component_completed

  def show
    case step
    when :add_shades
      @component.shades = ["", ""] if @component.shades.nil?
    when :add_cmrs
      create_required_cmrs
    # TODO: in all new flows, remove last step and use wizard default
    when :component_completed
      return redirect_to responsible_person_notification_draft_index_path(@notification.responsible_person, @notification)
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
      render_contains_cmrs
    when :add_cmrs
      update_add_cmrs
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

  def finish_wizard_path
    responsible_person_notification_draft_index_path(@notification.responsible_person, @notification)
  end

  def update_number_of_shades
    case params.dig(:component, :number_of_shades)
    when "single-or-no-shades", "multiple-shades-different-notification"
      @component.shades = nil
      @component.add_shades
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

  def render_contains_cmrs
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

  def component_params
    params.fetch(:component, {})
      .permit(
        :name,
        :physical_form,
        :special_applicator,
        :other_special_applicator,
        :sub_sub_category,
        :notification_type,
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
end

