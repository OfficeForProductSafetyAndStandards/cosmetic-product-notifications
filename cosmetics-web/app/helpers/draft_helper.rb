module DraftHelper
  NANOMATERIALS_SECTION   = "nanomaterials".freeze
  PRODUCT_DETAILS_SECTION = "product_details".freeze
  MULTI_ITEMS_KIT_SECTION = "multi_item_kit".freeze
  ITEMS_SECTION           = "items".freeze
  ACCEPT_SECTION          = "accept".freeze

  POSSIBLE_STEPS_MATRIX = {
    "empty" => { NANOMATERIALS_SECTION => false,
                 PRODUCT_DETAILS_SECTION => false,
                 MULTI_ITEMS_KIT_SECTION => false,
                 ITEMS_SECTION => false,
                 ACCEPT_SECTION => false },
    "product_name_added" => { NANOMATERIALS_SECTION => false,
                              PRODUCT_DETAILS_SECTION => false,
                              MULTI_ITEMS_KIT_SECTION => false,
                              ITEMS_SECTION => false,
                              ACCEPT_SECTION => false },
    "ready_for_nanomaterials" => { NANOMATERIALS_SECTION => true,
                                   PRODUCT_DETAILS_SECTION => false,
                                   MULTI_ITEMS_KIT_SECTION => false,
                                   ITEMS_SECTION => false,
                                   ACCEPT_SECTION => false },
    "details_complete" => { NANOMATERIALS_SECTION => true,
                            PRODUCT_DETAILS_SECTION => true,
                            MULTI_ITEMS_KIT_SECTION => true,
                            ITEMS_SECTION => false,
                            ACCEPT_SECTION => false },
    "ready_for_components" => { NANOMATERIALS_SECTION => true,
                                PRODUCT_DETAILS_SECTION => true,
                                MULTI_ITEMS_KIT_SECTION => true,
                                ITEMS_SECTION => true,
                                ACCEPT_SECTION => false },
    "components_complete" => { NANOMATERIALS_SECTION => true,
                               PRODUCT_DETAILS_SECTION => true,
                               MULTI_ITEMS_KIT_SECTION => true,
                               ITEMS_SECTION => true,
                               ACCEPT_SECTION => true },
  }.freeze

  def section_can_be_used?(section)
    POSSIBLE_STEPS_MATRIX[@notification.state][section]
  end

  def product_badge(notification)
    id = "product-status"

    if notification.state_lower_than?(NotificationStateConcern::READY_FOR_NANOMATERIALS)
      in_progress_badge(id, :product)
    else
      complete_badge(id, :product)
    end
  end

  def multi_item_kit_badge(notification)
    id = "multi-item-status"

    return cannot_start_yet_badge(id) unless section_can_be_used?(MULTI_ITEMS_KIT_SECTION)

    case notification.state.to_sym
    when Notification::DETAILS_COMPLETE
      not_started_badge(id, :multi_item_kit)
    when Notification::READY_FOR_COMPONENTS, Notification::COMPONENTS_COMPLETE, Notification::DRAFT_COMPLETE, Notification::NOTIFICATION_COMPLETE
      complete_badge(id, :multi_item_kit)
    else
      cannot_start_yet_badge(id, :multi_item_kit)
    end
  end

  def component_badge(component, override_id: nil)
    id = override_id || html_id_for(component)
    return cannot_start_yet_badge(id, :component) unless section_can_be_used?(ITEMS_SECTION)

    notification = component.notification
    if notification.empty? || notification.product_name_added? || notification.details_complete?
      cannot_start_yet_badge(id, :component)
    elsif component.empty?
      not_started_badge(id, :component)
    elsif component.component_complete?
      complete_badge(id, :component)
    else
      cannot_start_yet_badge(id, :component)
    end
  end

  def component_link(component, index)
    text = component.name || "Item ##{index + 1}"

    if section_can_be_used?(ITEMS_SECTION)
      link_to(text,
              new_responsible_person_notification_component_build_path(@notification.responsible_person, @notification, component),
              class: "govuk-link govuk-link--no-visited-state",
              aria: { describedby: html_id_for(component) })
    else
      text
    end
  end

  def product_link(step)
    hidden_text = " - #{step.to_s.humanize.downcase}"
    link_to(
            responsible_person_notification_product_path(@notification.responsible_person, @notification, step),
            class: "govuk-link app-task-list__tag govuk-link--no-visited-state",
            aria: { describedby: step }) do
              content_tag(:span, "Go to question") + content_tag(:span, hidden_text, class: "govuk-visually-hidden")
            end
  end

  def product_details_link(component)
    hidden_text = " - product details"
    link_to(
            new_responsible_person_notification_component_build_path(@notification.responsible_person, @notification, component),
            class: "govuk-link app-task-list__tag govuk-link--no-visited-state") do
              content_tag(:span, "Go to question") + content_tag(:span, hidden_text, class: "govuk-visually-hidden")
            end
  end

  def nanomaterial_link(nano_material, index, step)
    hidden_text = ["nanomaterial", "##{index+1}", step.to_s.humanize.downcase]

    link_to(
            responsible_person_notification_nanomaterial_build_path(@notification.responsible_person, @notification, nano_material, step),
            class: "govuk-link app-task-list__tag govuk-link--no-visited-state",
            aria: { describedby: hidden_text.join("_") }) do
              content_tag(:span, "Go to question") + content_tag(:span, " - #{hidden_text.join(" ")}", class: "govuk-visually-hidden")
            end
  end

  def nanomaterials_summary_badge(notification)
    id = "nanomaterials-status"

    return cannot_start_yet_badge(id, :nano_materials) unless section_can_be_used?(NANOMATERIALS_SECTION)

    if notification.nano_materials.empty?
      not_started_badge(id, :nano_materials)
    elsif notification.nano_materials.all?(&:completed?)
      complete_badge(id, :nano_materials)
    elsif notification.nano_materials.any?(&:blocked?)
      blocked_badge(id, :nano_materials)
    else
      in_progress_badge(id, :nano_materials)
    end
  end

  def nanomaterial_badge(nano_material, index)
    id = html_id_for(nano_material)
    hidden_text = nano_material&.name.present? ? nano_material.name : "nanomaterial ##{index+1}"

    return cannot_start_yet_badge(id, hidden_text) unless section_can_be_used?(NANOMATERIALS_SECTION)

    if nano_material.completed?
      complete_badge(id, hidden_text)
    elsif nano_material.blocked?
      blocked_badge(id, hidden_text)
    else
      not_started_badge(id, hidden_text)
    end
  end

  def complete_badge(id, hidden_text)
    badge("complete", "", id, hidden_text)
  end

  def not_started_badge(id, hidden_text)
    badge("not started", "govuk-tag--grey", id, hidden_text)
  end

  def in_progress_badge(id, hidden_text)
    badge("in progress", "govuk-tag--blue", id, hidden_text)
  end

  def cannot_start_yet_badge(id, hidden_text)
    badge("cannot start yet", "govuk-tag--grey", id, hidden_text)
  end

  def blocked_badge(id, hidden_text)
    badge("blocked", "opss-tag--red", id, hidden_text)
  end

  def badge(caption, css_classes, id, hidden_text)
    hidden_text = hidden_text.to_s.humanize + " "
    hidden_text_tag = content_tag(:span, hidden_text, class: "govuk-visually-hidden")
    content_tag(:b, class: "govuk-tag app-task-list__tag #{css_classes}", id: id) do
      hidden_text_tag + content_tag(:span, caption)
    end
  end

  def section_number(section)
    if section == PRODUCT_DETAILS_SECTION
      return @notification.nano_materials.present? ? "3." : "2."
    end
    if section == MULTI_ITEMS_KIT_SECTION
      return @notification.nano_materials.present? ? "3." : "2."
    end
    if section == ITEMS_SECTION
      return @notification.nano_materials.present? ? "4." : "3."
    end

    if section == ACCEPT_SECTION
      base_number = 3 # for simple product
      base_number += 1 if @notification.nano_materials.present?
      base_number += 1 if @notification.multi_component?
      "#{base_number}."
    end
  end

  def nano_materials_blocked?
    @notification.nano_materials.any?(&:blocked?)
  end

  def nano_material_should_be_notified?
    @notification.nano_materials.any?(&:toxicology_required?)
  end

  def nano_material_conforms_to_restrictions?
    @notification.nano_materials.all?(&:conforms_to_restrictions?)
  end

  def first_non_notified_blocked_nanomaterial_name
    @notification.nano_materials.find(&:toxicology_required?)&.name
  end

  def first_restricted_blocked_nanomaterial_name
    @notification.nano_materials.find { |n| !n.conforms_to_restrictions? }&.name
  end

  def incomplete_progress
    content_tag(:p, class: "govuk-body") do
      "You have completed #{sections_completed} of #{total_sections_count} sections"
    end
  end

  def total_sections_count
    count = 3
    count += 1 if @notification.nano_materials.present?
    count += 1 if @notification.multi_component?
    count
  end

  def sections_completed
    case @notification.state.to_sym
    when NotificationStateConcern::EMPTY, NotificationStateConcern::PRODUCT_NAME_ADDED
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
