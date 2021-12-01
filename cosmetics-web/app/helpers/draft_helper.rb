module DraftHelper
  NANOMATERIALS_SECTION   = 'nanomaterials'
  PRODUCT_DETAILS_SECTION = 'product_details'
  MULTI_ITEMS_KIT_SECTION = 'multi_item_kit'
  ITEMS_SECTION           = 'items'
  ACCEPT_SECTION          = 'accept'

  POSSIBLE_STEPS_MATRIX = {
    'empty' => { NANOMATERIALS_SECTION => false,
                 PRODUCT_DETAILS_SECTION => false,
                 MULTI_ITEMS_KIT_SECTION => false,
                 ITEMS_SECTION => false,
                 ACCEPT_SECTION => false },
    'product_name_added' => { NANOMATERIALS_SECTION => false,
                              PRODUCT_DETAILS_SECTION => false,
                              MULTI_ITEMS_KIT_SECTION => false,
                              ITEMS_SECTION => false,
                              ACCEPT_SECTION => false },

    'ready_for_nanomaterials' => { NANOMATERIALS_SECTION => true,
                                   PRODUCT_DETAILS_SECTION => false,
                                   MULTI_ITEMS_KIT_SECTION => false,
                                   ITEMS_SECTION => false,
                                   ACCEPT_SECTION => false },
    'details_complete' => { NANOMATERIALS_SECTION => true,
                            PRODUCT_DETAILS_SECTION => true,
                            MULTI_ITEMS_KIT_SECTION => true,
                            ITEMS_SECTION => false,
                            ACCEPT_SECTION => false },
    'ready_for_components' => { NANOMATERIALS_SECTION => true,
                                PRODUCT_DETAILS_SECTION => true,
                                MULTI_ITEMS_KIT_SECTION => true,
                                ITEMS_SECTION => true,
                                ACCEPT_SECTION => false },
    'components_complete' => { NANOMATERIALS_SECTION => true,
                               PRODUCT_DETAILS_SECTION => true,
                               MULTI_ITEMS_KIT_SECTION => true,
                               ITEMS_SECTION => true,
                               ACCEPT_SECTION => true },
  }

  def section_can_be_used?(section)
    POSSIBLE_STEPS_MATRIX[@notification.state][section]
  end

  def product_badge(notification)
    if notification.state == 'empty'
      not_started_badge
    else
      completed_badge
    end
  end

  def multi_item_kit_badge(notification)
    return cannot_start_yet_badge if !section_can_be_used?(MULTI_ITEMS_KIT_SECTION)

    if notification.state == 'details_complete'
      not_started_badge
    elsif ['ready_for_components', 'components_complete', 'draft_complete', 'notification_complete'].include? notification.state
      completed_badge
    else
      cannot_start_yet_badge
    end
  end

  def component_badge(component)
    # quarantine - not sure why its there
    # return cannot_start_yet_badge unless component
    return cannot_start_yet_badge if !section_can_be_used?(ITEMS_SECTION)

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

  def component_link(component, index)
    text = if component.name
      component.name
    else
      "Item ##{ index+1 }"
    end

    if section_can_be_used?(ITEMS_SECTION)
      link_to text, new_responsible_person_notification_component_build_path(@notification.responsible_person, @notification, component), class: "govuk-link govuk-link--no-visited-state"
    else
      text
    end
  end

  def nanomaterial_link(nano_element, index)
    text = if nano_element.inci_name
      nano_element.inci_name
    else
      "Nanomaterial ##{ index+1 }"
    end

    if section_can_be_used?(NANOMATERIALS_SECTION) && !nano_element.blocked?
      link_to text, new_responsible_person_notification_nanomaterial_build_path(@notification.responsible_person, @notification, nano_element), class: "govuk-link govuk-link--no-visited-state"
    else
      text
    end
  end

  def nanomaterial_badge(nano_element)
    return cannot_start_yet_badge if !section_can_be_used?(NANOMATERIALS_SECTION)

    if nano_element.completed?
      completed_badge
    elsif nano_element.blocked?
      blocked_badge
    else
      not_started_badge
    end
  end

  def completed_badge
    '<b class="govuk-tag app-task-list__tag" id="product-status">Completed</b>'.html_safe
  end

  def not_started_badge
    '<b class="govuk-tag govuk-tag--grey app-task-list__tag" id="product-details-status">Not started</b>'.html_safe
  end

  def cannot_start_yet_badge
    '<b class="govuk-tag govuk-tag--grey app-task-list__tag">Cannot start yet</b>'.html_safe
  end

  def blocked_badge
    '<b class="govuk-tag opss-tag--red app-task-list__tag">Blocked</b>'.html_safe
  end

  def progress_bar
    '<span class="govuk-visually-hidden">The task list is </span><span class="govuk-!-font-weight-bold">Incomplete</span>: 1 of 5 sections have been completed.'.html_safe
  end

  def section_number(section)
    if section == PRODUCT_DETAILS_SECTION
      return @notification.nano_materials.present? ? '3.' : '2.'
    end
    if section == MULTI_ITEMS_KIT_SECTION
      return @notification.nano_materials.present? ? '3.' : '2.'
    end
    if section == ITEMS_SECTION
      return @notification.nano_materials.present? ? '4.' : '3.'
    end
    if section == ACCEPT_SECTION
      base_number = 3 # for simple product
      base_number += 1 if @notification.nano_materials.present?
      base_number += 1 if @notification.multi_component?
      return "#{base_number}."
    end
  end
end
