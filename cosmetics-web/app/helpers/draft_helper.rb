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
    id = "product-status"

    if notification.state == 'empty'
      not_started_badge(id)
    else
      completed_badge(id)
    end
  end

  def multi_item_kit_badge(notification)
    id = "multi-item-status"

    return cannot_start_yet_badge(id) if !section_can_be_used?(MULTI_ITEMS_KIT_SECTION)

    if notification.state == 'details_complete'
      not_started_badge(id)
    elsif ['ready_for_components', 'components_complete', 'draft_complete', 'notification_complete'].include? notification.state
      completed_badge(id)
    else
      cannot_start_yet_badge(id)
    end
  end

  def component_badge(component, override_id: nil)
    if override_id
      id = override_id
    else
      id = html_id_for(component)
    end
    # quarantine - not sure why its there
    # return cannot_start_yet_badge unless component
    return cannot_start_yet_badge(id) if !section_can_be_used?(ITEMS_SECTION)

    if ['empty', 'product_name_added', 'details_complete'].include? component.notification.state
      cannot_start_yet_badge(id)
    elsif component.state == 'empty'
      not_started_badge(id)
    elsif component.state == 'component_complete'
      completed_badge(id)
    else
      cannot_start_yet_badge(id)
    end
  end

  def component_link(component, index)
    text = if component.name
      component.name
    else
      "Item ##{ index+1 }"
    end

    if section_can_be_used?(ITEMS_SECTION)
      link_to text, new_responsible_person_notification_component_build_path(@notification.responsible_person, @notification, component), class: "govuk-link govuk-link--no-visited-state", aria: { describedby: html_id_for(component) }
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
      aria_id = html_id_for(nano_element)
      link_to text, new_responsible_person_notification_nanomaterial_build_path(@notification.responsible_person, @notification, nano_element), class: "govuk-link govuk-link--no-visited-state", aria: { describedby: aria_id }
    else
      text
    end
  end

  def nanomaterial_badge(nano_element)
    id = html_id_for(nano_element)

    return cannot_start_yet_badge(id) if !section_can_be_used?(NANOMATERIALS_SECTION)

    if nano_element.completed?
      completed_badge(id)
    elsif nano_element.blocked?
      blocked_badge(id)
    else
      not_started_badge(id)
    end
  end

  def completed_badge(id)
    badge("Completed", "", id)
  end

  def not_started_badge(id)
    badge("Not started", "govuk-tag--grey", id)
  end

  def cannot_start_yet_badge(id)
    badge("Cannot start yet", "govuk-tag--grey", id)
  end

  def blocked_badge(id)
    badge("Blocked", "govuk-tag--red", id)
  end

  def badge(caption, css_classes, id)
    "<b class=\"govuk-tag app-task-list__tag #{css_classes}\" id=\"#{id}\">#{caption}</b>".html_safe
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

  def nano_materials_blocked?
    @notification.nano_materials.map(&:nano_elements).flatten.any? { |n| n.blocked? }
  end

  def nano_material_should_be_notified?
    @notification.nano_materials.map(&:nano_elements).flatten.any? { |n| n.toxicology_required? }
  end

  def nano_material_conforms_to_restrictions?
    @notification.nano_materials.map(&:nano_elements).flatten.all? { |n| n.conforms_to_restrictions? }
  end

  def first_blocked_nanomaterial_name
    nano = @notification.nano_materials.map(&:nano_elements).flatten.first { |n| n.toxicology_required? }
    nano.inci_name
  end

  def progress_bar
    "<span class=\"govuk-visually-hidden\">The task list is </span><span class=\"govuk-!-font-weight-bold\">Incomplete</span>: #{sections_completed} of #{total_sections_count} tasks have been completed.".html_safe
  end

  def total_sections_count
    if @notification.nano_materials.present? && @notification.multi_component?
      return 5
    end
    if @notification.nano_materials.present? || @notification.multi_component?
      return 4
    end
    3
  end

  def sections_completed
    case @notification.state.to_sym
    when NotificationStateConcern::EMPTY
      0
    when NotificationStateConcern::READY_FOR_NANOMATERIALS
      1
    when NotificationStateConcern::DETAILS_COMPLETE
      if @notification.nano_materials.present?
        2
      else
        1
      end
    when NotificationStateConcern::READY_FOR_COMPONENTS
      if @notification.nano_materials.present? && @notification.multi_component?
        3
      elsif @notification.nano_materials.present? || @notification.multi_component?
        2
      else
        1
      end
    when NotificationStateConcern::COMPONENTS_COMPLETE
      if @notification.nano_materials.present? && @notification.multi_component?
        4
      elsif @notification.nano_materials.present? || @notification.multi_component?
        3
      else
        2
      end
    end
  end

  def html_id_for(obj)
    "#{obj.class.name.downcase}-#{obj.id}-status"
  end
end
