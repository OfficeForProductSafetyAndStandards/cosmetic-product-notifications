module DraftHelper
  def product_badge(notification)
    if notification.state == 'empty'
      not_started_badge
    else
      completed_badge
    end
  end

  def product_kit_badge(notification)
    if notification.state == 'empty'
      cannot_start_yet_badge
    elsif notification.state == 'details_complete'
      not_started_badge
    elsif ['ready_for_components', 'components_complete', 'draft_complete', 'notification_complete'].include? notification.state
      completed_badge
    else
      cannot_start_yet_badge
    end
  end

  def component_badge(component)
    return cannot_start_yet_badge unless component

    if ['empty', 'product_name_added', 'details_complete'].include? component.notification.state
      cannot_start_yet_badge
    elsif component.state == 'empty'
      not_started_badge
    elsif component.state == 'component_complete'
      completed_badge
    else
      cannot_start_yet_badge
    end
  end

  def nanomaterial_badge(nanomaterial)
    cannot_start_yet_badge
  end


  def component_link(component, index)
    text = if component.name
      component.name
    else
      "Item ##{ index+1 }"
    end

    if ['empty', 'product_name_added', 'details_complete'].include? component.notification.state
      text
    else
      link_to text, new_responsible_person_notification_component_build_path(@notification.responsible_person, @notification, component), class: "govuk-link govuk-link--no-visited-state"
    end
  end

  def nanomaterial_link(nano_element, index)
    text = if nano_element.inci_name
      nano_element.inci_name
    else
      "Item ##{ index+1 }"
    end

    if ['empty', 'product_name_added', 'details_complete'].include? nano_element.nano_material.notification.state
      text
    else
      link_to text, new_responsible_person_notification_nanomaterial_build_path(@notification.responsible_person, @notification, nano_element), class: "govuk-link govuk-link--no-visited-state"
    end
  end

  def completed_badge
    '<b class="govuk-tag app-task-list__tag" id="product-status">Completed</b>'.html_safe
  end

  def not_started_badge
    '<b class="govuk-tag govuk-tag--grey app-task-list__tag" id="product-details-status">Not started</b>'.html_safe
  end

  def cannot_start_yet_badge
    '<b class="govuk-tag govuk-tag--grey app-task-list__tag" id="accept-status">Cannot start yet</b>'.html_safe
  end

  def accept_section_number(notification)
    if notification.multi_component?
      '4. '
    else
      '3. '
    end
  end

  def progress_bar
    '<span class="govuk-visually-hidden">The task list is </span><span class="govuk-!-font-weight-bold">Incomplete</span>: 1 of 5 sections have been completed.'.html_safe
  end
end
